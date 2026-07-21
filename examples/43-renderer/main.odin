package main

import "core:fmt"

Resource_Handle :: struct {
    index: int,
    generation: u32,
}

Resource_Slot :: struct {
    generation: u32,
    alive: bool,
}

resolve :: proc(slots: []Resource_Slot, handle: Resource_Handle) -> bool {
    if handle.index < 0 || handle.index >= len(slots) {
        return false
    }
    slot := slots[handle.index]
    return slot.alive && slot.generation == handle.generation
}

main :: proc() {
    slots := []Resource_Slot{
        {generation = 2, alive = true},
        {generation = 4, alive = false},
    }
    valid := Resource_Handle{index = 0, generation = 2}
    stale := Resource_Handle{index = 0, generation = 1}
    fmt.println("valid:", resolve(slots, valid))
    fmt.println("stale:", resolve(slots, stale))
}