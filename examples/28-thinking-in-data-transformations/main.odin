package main

import "core:fmt"

integrate :: proc(positions, velocities: []f32, dt: f32) {
    assert(len(positions) == len(velocities))
    for i in 0..<len(positions) {
        positions[i] += velocities[i] * dt
    }
}

decay :: proc(lifetimes: []f32, dt: f32) {
    for i in 0..<len(lifetimes) {
        lifetimes[i] -= dt
    }
}

main :: proc() {
    positions := [4]f32{0, 10, 20, 30}
    velocities := [4]f32{1, -2, 3, -4}
    lifetimes := [4]f32{5, 4, 3, 2}

    integrate(positions[:], velocities[:], 0.5)
    decay(lifetimes[:], 0.5)

    fmt.println("positions:", positions)
    fmt.println("lifetimes:", lifetimes)
}
