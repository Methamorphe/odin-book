package main

import "core:fmt"

Draw_Command :: struct {
    mesh: u32,
    material: u32,
    depth: f32,
}

sort_key :: proc(command: Draw_Command) -> u64 {
    return (u64(command.material) << 32) | u64(command.mesh)
}

main :: proc() {
    commands := [3]Draw_Command{
        {mesh = 2, material = 1, depth = 4.0},
        {mesh = 1, material = 2, depth = 2.0},
        {mesh = 1, material = 1, depth = 8.0},
    }

    for command in commands {
        fmt.println("draw key:", sort_key(command), " depth:", command.depth)
    }
}