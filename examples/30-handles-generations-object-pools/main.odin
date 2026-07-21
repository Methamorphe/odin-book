package main

import "core:fmt"

CAPACITY :: 4

Handle :: struct {
    index: int,
    generation: u32,
}

Pool :: struct {
    values: [CAPACITY]int,
    generations: [CAPACITY]u32,
    alive: [CAPACITY]bool,
}

create :: proc(pool: ^Pool, value: int) -> (Handle, bool) {
    for i in 0..<CAPACITY {
        if !pool.alive[i] {
            pool.alive[i] = true
            pool.values[i] = value
            return Handle{index = i, generation = pool.generations[i]}, true
        }
    }
    return {}, false
}

get :: proc(pool: ^Pool, handle: Handle) -> (^int, bool) {
    if handle.index < 0 || handle.index >= CAPACITY {
        return nil, false
    }
    if !pool.alive[handle.index] {
        return nil, false
    }
    if pool.generations[handle.index] != handle.generation {
        return nil, false
    }
    return &pool.values[handle.index], true
}

destroy :: proc(pool: ^Pool, handle: Handle) -> bool {
    _, ok := get(pool, handle)
    if !ok {
        return false
    }
    pool.alive[handle.index] = false
    pool.generations[handle.index] += 1
    return true
}

main :: proc() {
    pool: Pool
    first, first_created := create(&pool, 42)
    assert(first_created)
    value, found := get(&pool, first)
    assert(found)
    fmt.println("first value:", value^)

    assert(destroy(&pool, first))
    second, second_created := create(&pool, 99)
    assert(second_created)

    _, stale_found := get(&pool, first)
    current, current_found := get(&pool, second)
    fmt.println("stale resolves:", stale_found)
    fmt.println("current resolves:", current_found, " value:", current^)
}
