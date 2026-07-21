package main

import "core:math"

world_fixed_update_motion :: proc(world: ^World, dt: f32) {
    if world.paused { return }
    for index in world.motion_set.dense[:world.motion_set.count] {
        if !world.entities[index].enabled || !dense_set_contains(&world.transform_set, index) { continue }
        transform := &world.transforms[index]
        motion := &world.motions[index]
        motion.velocity = vec2_add(motion.velocity, vec2_scale(motion.acceleration, dt))
        if motion.drag > 0 {
            motion.velocity = vec2_scale(motion.velocity, max(0.0, 1.0-motion.drag*dt))
        }
        speed_squared := vec2_length_squared(motion.velocity)
        if motion.max_speed > 0 && speed_squared > motion.max_speed*motion.max_speed {
            scale := motion.max_speed/f32(math.sqrt(f64(speed_squared)))
            motion.velocity = vec2_scale(motion.velocity, scale)
        }
        transform.position = vec2_add(transform.position, vec2_scale(motion.velocity, dt))
        transform.position.x = clamp(transform.position.x, world.bounds.min.x, world.bounds.max.x)
        transform.position.y = clamp(transform.position.y, world.bounds.min.y, world.bounds.max.y)
    }
    world.stats.fixed_updates += 1
}

world_update_lifetimes :: proc(world: ^World, dt: f32) {
    pending: [MAX_ENTITIES]Entity_ID
    pending_count := 0
    i := 0
    for i < world.lifetime_set.count {
        index := world.lifetime_set.dense[i]
        lifetime := &world.lifetimes[index]
        lifetime.remaining -= dt
        if lifetime.remaining <= 0 {
            entity := Entity_ID{index, world.entities[index].generation}
            if lifetime.destroy_on_expire && pending_count < len(pending) {
                pending[pending_count] = entity
                pending_count += 1
                i += 1
            } else {
                _ = world_remove_component_index(world, entity, .Lifetime, &world.lifetime_set)
            }
        } else {
            i += 1
        }
    }
    for entity in pending[:pending_count] {
        _ = world_destroy(world, entity)
    }
}

world_update_health :: proc(world: ^World, dt: f32) {
    for index in world.health_set.dense[:world.health_set.count] {
        health := &world.health[index]
        health.invulnerable_time = max(0.0, health.invulnerable_time-dt)
        health.current = clamp(health.current, 0, health.maximum)
    }
}

world_update_players :: proc(world: ^World, actions: ^Action_Map, dt: f32) {
    for index in world.player_set.dense[:world.player_set.count] {
        if !world.entities[index].enabled || !dense_set_contains(&world.motion_set, index) { continue }
        player := &world.players[index]
        motion := &world.motions[index]
        horizontal := action_state(actions, .Move_Right).value+action_state(actions, .Move_Left).value
        vertical := action_state(actions, .Move_Up).value+action_state(actions, .Move_Down).value
        movement := Vec2{horizontal, vertical}
        length_squared := vec2_length_squared(movement)
        if length_squared > 1 {
            inverse := 1.0/f32(math.sqrt(f64(length_squared)))
            movement = vec2_scale(movement, inverse)
        }
        motion.acceleration = vec2_scale(movement, player.move_speed*8)
        player.dash_remaining = max(0.0, player.dash_remaining-dt)
        if action_state(actions, .Dash).pressed && player.dash_remaining <= 0 {
            direction := movement
            if vec2_length_squared(direction) == 0 { direction = {1, 0} }
            motion.velocity = vec2_scale(direction, player.dash_speed)
            player.dash_remaining = player.dash_cooldown
        }
    }
}

world_update_enemies :: proc(world: ^World, dt: f32) {
    for index in world.enemy_set.dense[:world.enemy_set.count] {
        if !world.entities[index].enabled || !dense_set_contains(&world.motion_set, index) || !dense_set_contains(&world.transform_set, index) { continue }
        enemy := &world.enemies[index]
        motion := &world.motions[index]
        enemy.think_timer -= dt
        if enemy.think_timer > 0 { continue }
        enemy.think_timer = 0.1
        if !world_entity_valid(world, enemy.target) || !dense_set_contains(&world.transform_set, enemy.target.index) {
            motion.acceleration = {}
            continue
        }
        position := world.transforms[index].position
        target_position := world.transforms[enemy.target.index].position
        delta := vec2_sub(target_position, position)
        length_squared := vec2_length_squared(delta)
        if length_squared > 0.0001 {
            direction := vec2_scale(delta, 1.0/f32(math.sqrt(f64(length_squared))))
            motion.acceleration = vec2_scale(direction, enemy.move_speed*6)
        } else {
            motion.acceleration = {}
        }
    }
}

world_update_cameras :: proc(world: ^World, dt: f32) {
    for index in world.camera_set.dense[:world.camera_set.count] {
        camera := &world.cameras[index]
        if !camera.active || !dense_set_contains(&world.transform_set, index) { continue }
        if !world_entity_valid(world, camera.follow) || !dense_set_contains(&world.transform_set, camera.follow.index) { continue }
        transform := &world.transforms[index]
        target := world.transforms[camera.follow.index].position
        t := clamp(camera.smoothing*dt, 0.0, 1.0)
        transform.position = vec2_add(transform.position, vec2_scale(vec2_sub(target, transform.position), t))
        world.active_camera = Entity_ID{index, world.entities[index].generation}
    }
}

world_fixed_update :: proc(world: ^World, actions: ^Action_Map, dt: f32) {
    if world.paused { return }
    world_update_players(world, actions, dt)
    world_update_enemies(world, dt)
    world_fixed_update_motion(world, dt)
    world_update_health(world, dt)
    world_update_lifetimes(world, dt)
    world_update_cameras(world, dt)
}

world_extract_render :: proc(world: ^World, renderer: ^Renderer) {
    camera_offset: Vec2
    if world_entity_valid(world, world.active_camera) && dense_set_contains(&world.transform_set, world.active_camera.index) {
        camera_offset = world.transforms[world.active_camera.index].position
    }
    for index in world.sprite_set.dense[:world.sprite_set.count] {
        if !world.entities[index].enabled || !dense_set_contains(&world.transform_set, index) { continue }
        sprite := world.sprites[index]
        if !sprite.visible { continue }
        transform := world.transforms[index]
        transform.position = vec2_sub(transform.position, camera_offset)
        transform.position = vec2_add(transform.position, {FRAMEBUFFER_WIDTH/2, FRAMEBUFFER_HEIGHT/2})
        transform.scale = sprite.size
        _ = render_push(&renderer.commands, Render_Command{
            kind = .Sprite,
            layer = sprite.layer,
            transform = transform,
            colour = sprite.tint,
            texture = sprite.texture,
            material = sprite.material,
        })
    }
    world.stats.render_extractions += 1
}

world_validate :: proc(world: ^World) -> bool {
    alive := 0
    for i in 0..<int(world.next_unused) {
        record := &world.entities[i]
        if !record.alive { continue }
        alive += 1
        if record.generation == 0 { return false }
        if .Transform in record.components != dense_set_contains(&world.transform_set, u32(i)) { return false }
        if .Motion in record.components != dense_set_contains(&world.motion_set, u32(i)) { return false }
        if .Sprite in record.components != dense_set_contains(&world.sprite_set, u32(i)) { return false }
        if .Collider in record.components != dense_set_contains(&world.collider_set, u32(i)) { return false }
        if .Health in record.components != dense_set_contains(&world.health_set, u32(i)) { return false }
        if .Lifetime in record.components != dense_set_contains(&world.lifetime_set, u32(i)) { return false }
        if .Player in record.components != dense_set_contains(&world.player_set, u32(i)) { return false }
        if .Enemy in record.components != dense_set_contains(&world.enemy_set, u32(i)) { return false }
        if .Camera in record.components != dense_set_contains(&world.camera_set, u32(i)) { return false }
        if .Name in record.components != dense_set_contains(&world.name_set, u32(i)) { return false }
    }
    return alive == world.stats.alive &&
        dense_set_validate(&world.transform_set) &&
        dense_set_validate(&world.motion_set) &&
        dense_set_validate(&world.sprite_set) &&
        dense_set_validate(&world.collider_set) &&
        dense_set_validate(&world.health_set) &&
        dense_set_validate(&world.lifetime_set) &&
        dense_set_validate(&world.player_set) &&
        dense_set_validate(&world.enemy_set) &&
        dense_set_validate(&world.camera_set) &&
        dense_set_validate(&world.name_set)
}

world_self_check :: proc() {
    world: World
    assert(result_is_ok(world_init(&world, Rect{{-100, -100}, {100, 100}})))
    player, result := world_spawn(&world, "player")
    assert(result_is_ok(result))
    assert(result_is_ok(world_add_motion(&world, player, Motion{velocity = {2, 0}, max_speed = 10})))
    assert(result_is_ok(world_add_health(&world, player, Health_Component{current = 10, maximum = 10})))
    actions: Action_Map
    world_fixed_update(&world, &actions, 0.5)
    transform, result := world_transform(&world, player)
    assert(result_is_ok(result) && transform.position.x == 1)
    damaged, result := world_damage(&world, player, 3)
    assert(result_is_ok(result) && damaged)
    assert(world_validate(&world))
    assert(result_is_ok(world_destroy(&world, player)))
    _, result = world_transform(&world, player)
    assert(result.error == .Stale_Handle)
}
