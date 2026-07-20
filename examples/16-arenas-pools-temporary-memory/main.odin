package main

import "core:fmt"

Handle :: struct {
    index: u32,
    generation: u32,
}

Slot :: struct {
    value: int,
    generation: u32,
    occupied: bool,
}

is_valid :: proc(slots: []Slot, handle: Handle) -> bool {
    index := int(handle.index)
    return index >= 0 && index < len(slots) &&
           slots[index].occupied &&
           slots[index].generation == handle.generation
}

main :: proc() {
    slots := []Slot{{value = 42, generation = 3, occupied = true}}
    valid := Handle{index = 0, generation = 3}
    stale := Handle{index = 0, generation = 2}

    fmt.println("valid:", is_valid(slots, valid))
    fmt.println("stale:", is_valid(slots, stale))
}
