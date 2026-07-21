package main

import "core:fmt"

Particle :: struct {
    x, y: f32,
    vx, vy: f32,
}

update_aos :: proc(particles: []Particle, dt: f32) {
    for i in 0..<len(particles) {
        particles[i].x += particles[i].vx * dt
        particles[i].y += particles[i].vy * dt
    }
}

update_soa :: proc(xs, ys, vxs, vys: []f32, dt: f32) {
    assert(len(xs) == len(ys))
    assert(len(xs) == len(vxs))
    assert(len(xs) == len(vys))
    for i in 0..<len(xs) {
        xs[i] += vxs[i] * dt
        ys[i] += vys[i] * dt
    }
}

main :: proc() {
    particles := [2]Particle{{0, 0, 1, 2}, {10, 20, -1, -2}}
    update_aos(particles[:], 0.5)

    xs := [2]f32{0, 10}
    ys := [2]f32{0, 20}
    vxs := [2]f32{1, -1}
    vys := [2]f32{2, -2}
    update_soa(xs[:], ys[:], vxs[:], vys[:], 0.5)

    fmt.println("AoS:", particles)
    fmt.println("SoA x:", xs, " y:", ys)
}
