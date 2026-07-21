package main

import "core:fmt"

PLUGIN_ABI_VERSION :: u32(1)

Plugin_API :: struct {
    abi_version: u32,
    state_size: int,
    update: proc(state: ^int, dt: f32),
}

update_counter :: proc(state: ^int, dt: f32) {
    state^ += int(dt * 60)
}

validate :: proc(api: Plugin_API) -> bool {
    return api.abi_version == PLUGIN_ABI_VERSION && api.update != nil && api.state_size == size_of(int)
}

main :: proc() {
    api := Plugin_API{abi_version = PLUGIN_ABI_VERSION, state_size = size_of(int), update = update_counter}
    state := 0
    if validate(api) {
        api.update(&state, 1.0 / 60.0)
    }
    fmt.println("state:", state)
}