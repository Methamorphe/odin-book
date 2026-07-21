package main

import "core:fmt"

Transform :: struct {
    x, y: f32,
    parent: int,
}

world_position :: proc(transforms: []Transform, index: int) -> (f32, f32) {
    x := transforms[index].x
    y := transforms[index].y
    parent := transforms[index].parent
    for parent >= 0 {
        x += transforms[parent].x
        y += transforms[parent].y
        parent = transforms[parent].parent
    }
    return x, y
}

main :: proc() {
    transforms := []Transform{
        {x = 10, y = 5, parent = -1},
        {x = 2, y = 3, parent = 0},
        {x = 1, y = -1, parent = 1},
    }
    x, y := world_position(transforms, 2)
    fmt.println("world position:", x, y)
}