package main

import "core:fmt"

UI_State :: struct {
    hot: u64,
    active: u64,
}

button :: proc(ui: ^UI_State, id: u64, hovered, pressed, released: bool) -> bool {
    if hovered {
        ui.hot = id
    }
    if hovered && pressed {
        ui.active = id
    }
    clicked := released && ui.active == id && hovered
    if released && ui.active == id {
        ui.active = 0
    }
    return clicked
}

main :: proc() {
    ui: UI_State
    _ = button(&ui, 42, true, true, false)
    clicked := button(&ui, 42, true, false, true)
    fmt.println("clicked:", clicked)
}