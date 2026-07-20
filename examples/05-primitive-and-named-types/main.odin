package main

import "core:fmt"

Texture_Handle :: distinct u32
Mesh_Handle    :: distinct u32

print_texture :: proc(handle: Texture_Handle) {
    fmt.println("texture handle:", u32(handle))
}

main :: proc() {
    texture := Texture_Handle(17)
    mesh := Mesh_Handle(17)

    print_texture(texture)
    // print_texture(mesh) // Uncomment to observe the type error.

    fmt.println("mesh handle:", u32(mesh))
}
