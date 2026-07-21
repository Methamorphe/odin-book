package main

import "core:fmt"

Shared_State :: struct {
    values: [4]int,
}

worker_range :: proc(state: ^Shared_State, first, last: int) {
    for i in first..<last {
        // Each worker owns a disjoint range, so no lock is required.
        state.values[i] = i * i
    }
}

main :: proc() {
    state := Shared_State{}

    worker_range(&state, 0, 2)
    worker_range(&state, 2, 4)

    fmt.println(state.values)
}