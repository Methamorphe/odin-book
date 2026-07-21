package main

import "core:fmt"

Entity :: struct { index, generation: u32 }
Position :: struct { x, y: f32 }
Velocity :: struct { x, y: f32 }
World :: struct {
    generations: [128]u32,
    alive: [128]bool,
    positions: [128]Position,
    velocities: [128]Velocity,
    has_position: [128]bool,
    has_velocity: [128]bool,
}

spawn :: proc(w: ^World) -> (Entity, bool) {
    for i in 0..<len(w.alive) {
        if !w.alive[i] {
            w.alive[i] = true
            if w.generations[i] == 0 { w.generations[i] = 1 }
            return Entity{u32(i), w.generations[i]}, true
        }
    }
    return {}, false
}

valid :: proc(w: ^World, e: Entity) -> bool {
    return e.index < u32(len(w.alive)) && w.alive[e.index] && w.generations[e.index] == e.generation
}

set_motion :: proc(w: ^World, e: Entity, p: Position, v: Velocity) -> bool {
    if !valid(w, e) { return false }
    w.positions[e.index] = p
    w.velocities[e.index] = v
    w.has_position[e.index] = true
    w.has_velocity[e.index] = true
    return true
}

update :: proc(w: ^World, dt: f32) {
    for i in 0..<len(w.alive) {
        if w.alive[i] && w.has_position[i] && w.has_velocity[i] {
            w.positions[i].x += w.velocities[i].x*dt
            w.positions[i].y += w.velocities[i].y*dt
        }
    }
}

main :: proc() {
    world: World
    e, ok := spawn(&world)
    assert(ok && set_motion(&world, e, {0, 0}, {2, -1}))
    update(&world, 0.5)
    fmt.println(world.positions[e.index])
}
