package main

World :: struct {
    generations: [MAX_ENTITIES]u32,
    alive:       [MAX_ENTITIES]bool,
    transforms:  [MAX_ENTITIES]Transform,
    assets:      [MAX_ENTITIES]Asset_Handle,
    count:       int,
}

entity_valid :: proc(world: ^World, entity: Entity) -> bool {
    index := int(entity.index)
    if index < 0 || index >= MAX_ENTITIES {
        return false
    }
    return world.alive[index] && world.generations[index] == entity.generation
}

spawn_entity :: proc(
    world: ^World,
    transform: Transform,
    asset: Asset_Handle,
) -> (Entity, bool) {
    for index in 0..<MAX_ENTITIES {
        if world.alive[index] {
            continue
        }

        world.alive[index] = true
        world.transforms[index] = transform
        world.assets[index] = asset
        world.count += 1

        return Entity{index = u32(index), generation = world.generations[index]}, true
    }

    return Entity{}, false
}

destroy_entity :: proc(world: ^World, entity: Entity) -> bool {
    if !entity_valid(world, entity) {
        return false
    }

    index := int(entity.index)
    world.alive[index] = false
    world.generations[index] += 1
    world.transforms[index] = Transform{}
    world.assets[index] = Asset_Handle{}
    world.count -= 1
    return true
}

get_transform :: proc(world: ^World, entity: Entity) -> (^Transform, bool) {
    if !entity_valid(world, entity) {
        return nil, false
    }
    return &world.transforms[int(entity.index)], true
}

update_world :: proc(world: ^World, dt: f32) {
    for index in 0..<MAX_ENTITIES {
        if !world.alive[index] {
            continue
        }

        transform := &world.transforms[index]
        transform.position.x += transform.velocity.x * dt
        transform.position.y += transform.velocity.y * dt
    }
}