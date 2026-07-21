package main

import "core:fmt"

CAPACITY :: 8

Entity :: struct {
    index: int,
    generation: u32,
}

World :: struct {
    generations: [CAPACITY]u32,
    alive: [CAPACITY]bool,
    has_position: [CAPACITY]bool,
    has_velocity: [CAPACITY]bool,
    positions: [CAPACITY][2]f32,
    velocities: [CAPACITY][2]f32,
}

create_entity :: proc(world: ^World) -> (Entity, bool) {
    for i in 0..<CAPACITY {
        if !world.alive[i] {
            world.alive[i] = true
            return Entity{index = i, generation = world.generations[i]}, true
        }
    }
    return {}, false
}

is_alive :: proc(world: ^World, entity: Entity) -> bool {
    return entity.index >= 0 &&
        entity.index < CAPACITY &&
        world.alive[entity.index] &&
        world.generations[entity.index] == entity.generation
}

movement_system :: proc(world: ^World, dt: f32) {
    for i in 0..<CAPACITY {
        if world.alive[i] && world.has_position[i] && world.has_velocity[i] {
            world.positions[i][0] += world.velocities[i][0] * dt
            world.positions[i][1] += world.velocities[i][1] * dt
        }
    }
}

main :: proc() {
    world: World
    entity, ok := create_entity(&world)
    assert(ok)

    i := entity.index
    world.has_position[i] = true
    world.has_velocity[i] = true
    world.positions[i] = {10, 20}
    world.velocities[i] = {2, -4}

    movement_system(&world, 0.5)
    fmt.println("alive:", is_alive(&world, entity))
    fmt.println("position:", world.positions[i])
}
