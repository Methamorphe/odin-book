package main

MAX_ENTITIES :: 64
MAX_ASSETS :: 32
MAX_RENDER_COMMANDS :: 128

Vec2 :: struct {
    x, y: f32,
}

Entity :: struct {
    index:      u32,
    generation: u32,
}

Asset_Handle :: struct {
    index:      u32,
    generation: u32,
}

Transform :: struct {
    position: Vec2,
    velocity: Vec2,
}

Render_Command :: struct {
    entity: Entity,
    asset:  Asset_Handle,
    position: Vec2,
}

Frame_Stats :: struct {
    frame_count:          u64,
    simulation_steps:     u64,
    extracted_commands:   u64,
    submitted_commands:   u64,
}