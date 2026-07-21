package main

import "core:fmt"

Engine :: struct {
    running: bool,
    frame_index: u64,
}

init_engine :: proc(engine: ^Engine) -> bool {
    engine.running = true
    engine.frame_index = 0
    return true
}

run_frame :: proc(engine: ^Engine) {
    engine.frame_index += 1
    if engine.frame_index >= 3 {
        engine.running = false
    }
}

shutdown_engine :: proc(engine: ^Engine) {
    fmt.println("frames:", engine.frame_index)
}

main :: proc() {
    engine: Engine
    if !init_engine(&engine) {
        return
    }
    defer shutdown_engine(&engine)

    for engine.running {
        run_frame(&engine)
    }
}