package main

import "core:fmt"

Transform :: struct { x, y: f32 }

translate :: proc(value: ^Transform, dx, dy: f32) {
    value.x += dx
    value.y += dy
}

main :: proc() {
    player := Transform{x = 2, y = 3}
    translate(&player, 5, -1)
    fmt.println(player)
}
