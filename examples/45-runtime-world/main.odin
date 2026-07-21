package main

import "core:fmt"

Entity :: struct {
    index: int,
    generation: u32,
}

World :: struct {
    generations: [8]u32,
    alive: [8]bool,
    positions: [8][2]f32,
}

create_entity :: proc(world: ^World, index: int) -> Entity {
    world.alive[index] = true
    return Entity{index = index, generation = world.generations[index]}
}

is_alive :: proc(world: ^World, entity: Entity) -> bool {
    return entity.index >= 0 && entity.index < len(world.alive) &&
           world.alive[entity.index] &&
           world.generations[entity.index] == entity.generation
}

destroy_entity :: proc(world: ^World, entity: Entity) {
    if is_alive(world, entity) {
        world.alive[entity.index] = false
        world.generations[entity.index] += 1
    }
}

main :: proc() {
    world: World
    entity := create_entity(&world, 2)
    world.positions[entity.index] = {4, 7}
    fmt.println("alive:", is_alive(&world, entity))
    destroy_entity(&world, entity)
    fmt.println("alive after destroy:", is_alive(&world, entity))
}