package main

Motion :: struct {
    velocity: Vec2,
    acceleration: Vec2,
    drag: f32,
    max_speed: f32,
}

Sprite_Component :: struct {
    texture: Texture_ID,
    material: Material_ID,
    size: Vec2,
    tint: Colour,
    layer: i16,
    visible: bool,
}

Collider_Component :: struct {
    half_extents: Vec2,
    offset: Vec2,
    trigger: bool,
    layer: u16,
    mask: u16,
}

Health_Component :: struct {
    current: i32,
    maximum: i32,
    invulnerable_time: f32,
}

Lifetime_Component :: struct {
    remaining: f32,
    destroy_on_expire: bool,
}

Player_Component :: struct {
    move_speed: f32,
    jump_strength: f32,
    dash_speed: f32,
    dash_cooldown: f32,
    dash_remaining: f32,
}

Enemy_Component :: struct {
    target: Entity_ID,
    move_speed: f32,
    contact_damage: i32,
    think_timer: f32,
}

Camera_Component :: struct {
    viewport: Rect,
    zoom: f32,
    follow: Entity_ID,
    smoothing: f32,
    active: bool,
}

world_add_component_index :: proc(world: ^World, entity: Entity_ID, component: Component, set: ^Dense_Index_Set) -> Result {
    if !world_entity_valid(world, entity) {
        world.stats.stale_accesses += 1
        return result_error(.Stale_Handle, "invalid entity handle")
    }
    if dense_set_contains(set, entity.index) {
        incl(&world.entities[entity.index].components, component)
        return result_ok()
    }
    _, result := dense_set_insert(set, entity.index)
    if !result_is_ok(result) {
        return result
    }
    incl(&world.entities[entity.index].components, component)
    return result_ok()
}

world_remove_component_index :: proc(world: ^World, entity: Entity_ID, component: Component, set: ^Dense_Index_Set) -> Result {
    if !world_entity_valid(world, entity) {
        return result_error(.Stale_Handle, "invalid entity handle")
    }
    if !dense_set_remove(set, entity.index) {
        return result_error(.Not_Found, "component not present")
    }
    excl(&world.entities[entity.index].components, component)
    return result_ok()
}

world_add_transform :: proc(world: ^World, entity: Entity_ID, value: Transform_2D) -> Result {
    result := world_add_component_index(world, entity, .Transform, &world.transform_set)
    if result_is_ok(result) { world.transforms[entity.index] = value }
    return result
}

world_add_name :: proc(world: ^World, entity: Entity_ID, text: string) -> Result {
    name, ok := name_from_string(text)
    if !ok { return result_error(.Invalid_Argument, "entity name too long") }
    result := world_add_component_index(world, entity, .Name, &world.name_set)
    if result_is_ok(result) { world.names[entity.index] = name }
    return result
}

world_add_motion :: proc(world: ^World, entity: Entity_ID, value: Motion) -> Result {
    result := world_add_component_index(world, entity, .Motion, &world.motion_set)
    if result_is_ok(result) { world.motions[entity.index] = value }
    return result
}

world_add_sprite :: proc(world: ^World, entity: Entity_ID, value: Sprite_Component) -> Result {
    if value.size.x < 0 || value.size.y < 0 {
        return result_error(.Invalid_Argument, "sprite size must be non-negative")
    }
    result := world_add_component_index(world, entity, .Sprite, &world.sprite_set)
    if result_is_ok(result) { world.sprites[entity.index] = value }
    return result
}

world_add_collider :: proc(world: ^World, entity: Entity_ID, value: Collider_Component) -> Result {
    if value.half_extents.x < 0 || value.half_extents.y < 0 {
        return result_error(.Invalid_Argument, "collider extents must be non-negative")
    }
    result := world_add_component_index(world, entity, .Collider, &world.collider_set)
    if result_is_ok(result) { world.colliders[entity.index] = value }
    return result
}

world_add_health :: proc(world: ^World, entity: Entity_ID, value: Health_Component) -> Result {
    if value.maximum <= 0 || value.current < 0 || value.current > value.maximum {
        return result_error(.Invalid_Argument, "invalid health component")
    }
    result := world_add_component_index(world, entity, .Health, &world.health_set)
    if result_is_ok(result) { world.health[entity.index] = value }
    return result
}

world_add_lifetime :: proc(world: ^World, entity: Entity_ID, value: Lifetime_Component) -> Result {
    if value.remaining < 0 {
        return result_error(.Invalid_Argument, "lifetime must be non-negative")
    }
    result := world_add_component_index(world, entity, .Lifetime, &world.lifetime_set)
    if result_is_ok(result) { world.lifetimes[entity.index] = value }
    return result
}

world_add_player :: proc(world: ^World, entity: Entity_ID, value: Player_Component) -> Result {
    result := world_add_component_index(world, entity, .Player, &world.player_set)
    if result_is_ok(result) { world.players[entity.index] = value }
    return result
}

world_add_enemy :: proc(world: ^World, entity: Entity_ID, value: Enemy_Component) -> Result {
    result := world_add_component_index(world, entity, .Enemy, &world.enemy_set)
    if result_is_ok(result) { world.enemies[entity.index] = value }
    return result
}

world_add_camera :: proc(world: ^World, entity: Entity_ID, value: Camera_Component) -> Result {
    result := world_add_component_index(world, entity, .Camera, &world.camera_set)
    if result_is_ok(result) {
        world.cameras[entity.index] = value
        if value.active { world.active_camera = entity }
    }
    return result
}

world_transform :: proc(world: ^World, entity: Entity_ID) -> (^Transform_2D, Result) {
    if !world_entity_valid(world, entity) {
        world.stats.stale_accesses += 1
        return nil, result_error(.Stale_Handle, "invalid entity handle")
    }
    if !dense_set_contains(&world.transform_set, entity.index) {
        return nil, result_error(.Not_Found, "transform not present")
    }
    return &world.transforms[entity.index], result_ok()
}

world_motion :: proc(world: ^World, entity: Entity_ID) -> (^Motion, Result) {
    if !world_entity_valid(world, entity) { return nil, result_error(.Stale_Handle, "invalid entity handle") }
    if !dense_set_contains(&world.motion_set, entity.index) { return nil, result_error(.Not_Found, "motion not present") }
    return &world.motions[entity.index], result_ok()
}

world_health_component :: proc(world: ^World, entity: Entity_ID) -> (^Health_Component, Result) {
    if !world_entity_valid(world, entity) { return nil, result_error(.Stale_Handle, "invalid entity handle") }
    if !dense_set_contains(&world.health_set, entity.index) { return nil, result_error(.Not_Found, "health not present") }
    return &world.health[entity.index], result_ok()
}

world_name :: proc(world: ^World, entity: Entity_ID) -> string {
    if !world_entity_valid(world, entity) || !dense_set_contains(&world.name_set, entity.index) {
        return ""
    }
    return name_string(&world.names[entity.index])
}

world_has_components :: proc(world: ^World, entity: Entity_ID, required: Component_Mask) -> bool {
    if !world_entity_valid(world, entity) { return false }
    return required <= world.entities[entity.index].components
}

world_damage :: proc(world: ^World, entity: Entity_ID, amount: i32, invulnerability: f32 = 0.1) -> (bool, Result) {
    health, result := world_health_component(world, entity)
    if !result_is_ok(result) { return false, result }
    if amount <= 0 || health.invulnerable_time > 0 { return false, result_ok() }
    health.current = max(0, health.current-amount)
    health.invulnerable_time = invulnerability
    return true, result_ok()
}

world_heal :: proc(world: ^World, entity: Entity_ID, amount: i32) -> (bool, Result) {
    health, result := world_health_component(world, entity)
    if !result_is_ok(result) { return false, result }
    if amount <= 0 || health.current >= health.maximum { return false, result_ok() }
    health.current = min(health.maximum, health.current+amount)
    return true, result_ok()
}
