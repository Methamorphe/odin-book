package main

import "core:fmt"

Texture_Handle :: distinct u32
Mesh_Handle :: distinct u32
Material_Handle :: distinct u32

Material :: struct {
    albedo: Texture_Handle,
    roughness: f32,
    metallic: f32,
}

main :: proc() {
    mesh := Mesh_Handle(7)
    material := Material{albedo = Texture_Handle(3), roughness = 0.65, metallic = 0.1}
    fmt.println("mesh:", u32(mesh))
    fmt.println("albedo:", u32(material.albedo), " roughness:", material.roughness)
}