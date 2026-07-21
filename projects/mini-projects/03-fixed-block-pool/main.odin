package main

import "core:fmt"

Handle :: struct { index, generation: u32 }
Slot :: struct { value: i64, generation: u32, occupied: bool }
Pool :: struct { slots: [32]Slot }

create :: proc(p: ^Pool, value: i64) -> (Handle, bool) {
    for i in 0..<len(p.slots) {
        if !p.slots[i].occupied {
            p.slots[i].occupied = true
            p.slots[i].value = value
            if p.slots[i].generation == 0 { p.slots[i].generation = 1 }
            return Handle{u32(i), p.slots[i].generation}, true
        }
    }
    return {}, false
}

get :: proc(p: ^Pool, h: Handle) -> (^i64, bool) {
    if h.index >= u32(len(p.slots)) { return nil, false }
    s := &p.slots[h.index]
    if !s.occupied || s.generation != h.generation { return nil, false }
    return &s.value, true
}

destroy :: proc(p: ^Pool, h: Handle) -> bool {
    if h.index >= u32(len(p.slots)) { return false }
    s := &p.slots[h.index]
    if !s.occupied || s.generation != h.generation { return false }
    s.occupied = false
    s.generation += 1
    if s.generation == 0 { s.generation = 1 }
    return true
}

main :: proc() {
    pool: Pool
    h, ok := create(&pool, 42)
    assert(ok)
    value, found := get(&pool, h)
    assert(found && value^ == 42)
    assert(destroy(&pool, h))
    _, stale := get(&pool, h)
    fmt.println("stale resolves:", stale)
}
