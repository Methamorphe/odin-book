package main

import "core:fmt"

Arena :: struct {
    storage: [4096]u8,
    offset:  int,
    peak:    int,
}

align_forward :: proc(value, alignment: int) -> int {
    mask := alignment - 1
    return (value + mask) & ~mask
}

arena_alloc :: proc(a: ^Arena, size, alignment: int) -> ([]u8, bool) {
    if size < 0 || alignment <= 0 || (alignment & (alignment - 1)) != 0 {
        return nil, false
    }
    start := align_forward(a.offset, alignment)
    end := start + size
    if end > len(a.storage) { return nil, false }
    a.offset = end
    if a.offset > a.peak { a.peak = a.offset }
    return a.storage[start:end], true
}

arena_reset :: proc(a: ^Arena) { a.offset = 0 }

main :: proc() {
    arena: Arena
    header, ok := arena_alloc(&arena, 24, 8)
    assert(ok && len(header) == 24)
    payload, ok := arena_alloc(&arena, 1000, 16)
    assert(ok && len(payload) == 1000)
    fmt.println("used:", arena.offset, "peak:", arena.peak)
    arena_reset(&arena)
    assert(arena.offset == 0)
}
