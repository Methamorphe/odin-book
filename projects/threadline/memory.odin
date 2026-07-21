package main

import "core:fmt"

Memory_Stats :: struct {
    capacity: u64,
    used: u64,
    peak: u64,
    allocations: u64,
    failures: u64,
    resets: u64,
}

Arena_Marker :: struct {
    offset: int,
}

Arena :: struct {
    storage: [256*1024]u8,
    offset: int,
    stats: Memory_Stats,
    name: Name,
}

Scratch :: struct {
    arena: Arena,
    frame_index: u64,
}

Fixed_Block_Pool :: struct {
    storage: [64*1024]u8,
    block_size: int,
    block_count: int,
    free_head: i32,
    next: [1024]i32,
    occupied: [1024]bool,
    generations: [1024]u32,
    live_count: int,
    peak_live: int,
    failures: u64,
}

Pool_Handle :: struct {
    index: u32,
    generation: u32,
}

align_forward :: proc(value, alignment: int) -> int {
    assert(alignment > 0)
    assert((alignment & (alignment-1)) == 0)
    mask := alignment-1
    return (value+mask)&~mask
}

arena_init :: proc(arena: ^Arena, label: string) -> Result {
    name, ok := name_from_string(label)
    if !ok {
        return result_error(.Invalid_Argument, "arena label is too long")
    }
    arena^ = Arena{name = name}
    arena.stats.capacity = u64(len(arena.storage))
    return result_ok()
}

arena_alloc :: proc(arena: ^Arena, size, alignment: int, zero: bool = false) -> ([]u8, Result) {
    if size < 0 || alignment <= 0 || (alignment&(alignment-1)) != 0 {
        arena.stats.failures += 1
        return nil, result_error(.Invalid_Argument, "invalid allocation request")
    }

    start := align_forward(arena.offset, alignment)
    end := start+size
    if end > len(arena.storage) {
        arena.stats.failures += 1
        return nil, result_error(.Capacity_Exceeded, "arena exhausted")
    }

    memory := arena.storage[start:end]
    arena.offset = end
    arena.stats.used = u64(arena.offset)
    arena.stats.allocations += 1
    if arena.stats.used > arena.stats.peak {
        arena.stats.peak = arena.stats.used
    }

    if zero {
        for &byte in memory {
            byte = 0
        }
    }

    return memory, result_ok()
}

arena_alloc_array :: proc(arena: ^Arena, count, element_size, alignment: int, zero: bool = false) -> ([]u8, Result) {
    if count < 0 || element_size < 0 {
        return nil, result_error(.Invalid_Argument, "negative array allocation")
    }
    if count != 0 && element_size > max(int)/count {
        return nil, result_error(.Invalid_Argument, "array allocation overflow")
    }
    return arena_alloc(arena, count*element_size, alignment, zero)
}

arena_mark :: proc(arena: ^Arena) -> Arena_Marker {
    return Arena_Marker{arena.offset}
}

arena_restore :: proc(arena: ^Arena, marker: Arena_Marker, zero_released: bool = false) -> Result {
    if marker.offset < 0 || marker.offset > arena.offset {
        return result_error(.Invalid_Argument, "invalid arena marker")
    }
    if zero_released {
        for i in marker.offset..<arena.offset {
            arena.storage[i] = 0
        }
    }
    arena.offset = marker.offset
    arena.stats.used = u64(arena.offset)
    return result_ok()
}

arena_reset :: proc(arena: ^Arena, zero_memory: bool = false) {
    if zero_memory {
        for i in 0..<arena.offset {
            arena.storage[i] = 0
        }
    }
    arena.offset = 0
    arena.stats.used = 0
    arena.stats.resets += 1
}

arena_remaining :: proc(arena: ^Arena) -> int {
    return len(arena.storage)-arena.offset
}

arena_contains :: proc(arena: ^Arena, memory: []u8) -> bool {
    if len(memory) == 0 {
        return true
    }
    begin := uintptr(raw_data(memory))
    arena_begin := uintptr(&arena.storage[0])
    arena_end := arena_begin+uintptr(len(arena.storage))
    return begin >= arena_begin && begin+uintptr(len(memory)) <= arena_end
}

scratch_init :: proc(scratch: ^Scratch) -> Result {
    return arena_init(&scratch.arena, "frame scratch")
}

scratch_begin_frame :: proc(scratch: ^Scratch, frame_index: u64) {
    assert(frame_index >= scratch.frame_index)
    arena_reset(&scratch.arena)
    scratch.frame_index = frame_index
}

pool_init :: proc(pool: ^Fixed_Block_Pool, block_size, block_count: int) -> Result {
    if block_size <= 0 || block_count <= 0 || block_count > len(pool.next) {
        return result_error(.Invalid_Argument, "invalid pool dimensions")
    }
    if block_size*block_count > len(pool.storage) {
        return result_error(.Capacity_Exceeded, "pool storage too small")
    }

    pool^ = Fixed_Block_Pool{
        block_size = block_size,
        block_count = block_count,
        free_head = 0,
    }

    for i in 0..<block_count {
        pool.next[i] = i+1 < block_count ? i32(i+1) : -1
        pool.generations[i] = 1
    }
    return result_ok()
}

pool_alloc :: proc(pool: ^Fixed_Block_Pool, zero: bool = false) -> (Pool_Handle, []u8, Result) {
    if pool.free_head < 0 {
        pool.failures += 1
        return {}, nil, result_error(.Capacity_Exceeded, "pool exhausted")
    }

    index := int(pool.free_head)
    pool.free_head = pool.next[index]
    pool.next[index] = -1
    pool.occupied[index] = true
    pool.live_count += 1
    if pool.live_count > pool.peak_live {
        pool.peak_live = pool.live_count
    }

    start := index*pool.block_size
    block := pool.storage[start:start+pool.block_size]
    if zero {
        for &byte in block {
            byte = 0
        }
    }

    handle := Pool_Handle{u32(index), pool.generations[index]}
    return handle, block, result_ok()
}

pool_resolve :: proc(pool: ^Fixed_Block_Pool, handle: Pool_Handle) -> ([]u8, Result) {
    if handle.index >= u32(pool.block_count) {
        return nil, result_error(.Invalid_Argument, "pool handle out of range")
    }
    index := int(handle.index)
    if !pool.occupied[index] || pool.generations[index] != handle.generation {
        return nil, result_error(.Stale_Handle, "stale pool handle")
    }
    start := index*pool.block_size
    return pool.storage[start:start+pool.block_size], result_ok()
}

pool_free :: proc(pool: ^Fixed_Block_Pool, handle: Pool_Handle, poison: bool = false) -> Result {
    if handle.index >= u32(pool.block_count) {
        return result_error(.Invalid_Argument, "pool handle out of range")
    }
    index := int(handle.index)
    if !pool.occupied[index] || pool.generations[index] != handle.generation {
        return result_error(.Stale_Handle, "stale pool handle")
    }

    if poison {
        start := index*pool.block_size
        for &byte in pool.storage[start:start+pool.block_size] {
            byte = 0xdd
        }
    }

    pool.occupied[index] = false
    pool.generations[index] = next_generation(pool.generations[index])
    pool.next[index] = pool.free_head
    pool.free_head = i32(index)
    pool.live_count -= 1
    return result_ok()
}

pool_validate :: proc(pool: ^Fixed_Block_Pool) -> bool {
    if pool.block_size <= 0 || pool.block_count <= 0 {
        return false
    }
    occupied_count := 0
    for i in 0..<pool.block_count {
        if pool.occupied[i] {
            occupied_count += 1
        }
        if pool.generations[i] == 0 {
            return false
        }
    }
    if occupied_count != pool.live_count {
        return false
    }

    free_seen: [1024]bool
    free_count := 0
    at := pool.free_head
    for at >= 0 {
        index := int(at)
        if index >= pool.block_count || free_seen[index] || pool.occupied[index] {
            return false
        }
        free_seen[index] = true
        free_count += 1
        at = pool.next[index]
    }
    return free_count+pool.live_count == pool.block_count
}

memory_report :: proc(arena: ^Arena, pool: ^Fixed_Block_Pool) {
    fmt.printf(
        "arena=%s used=%d peak=%d allocations=%d failures=%d resets=%d\n",
        name_string(&arena.name),
        arena.stats.used,
        arena.stats.peak,
        arena.stats.allocations,
        arena.stats.failures,
        arena.stats.resets,
    )
    fmt.printf(
        "pool block_size=%d live=%d peak=%d failures=%d\n",
        pool.block_size,
        pool.live_count,
        pool.peak_live,
        pool.failures,
    )
}

memory_self_check :: proc() {
    arena: Arena
    assert(result_is_ok(arena_init(&arena, "test")))
    first, result := arena_alloc(&arena, 128, 16, true)
    assert(result_is_ok(result) && len(first) == 128)
    marker := arena_mark(&arena)
    second, result := arena_alloc(&arena, 512, 32)
    assert(result_is_ok(result) && arena_contains(&arena, second))
    assert(result_is_ok(arena_restore(&arena, marker)))
    assert(arena.offset == marker.offset)

    pool: Fixed_Block_Pool
    assert(result_is_ok(pool_init(&pool, 64, 32)))
    handle, block, result := pool_alloc(&pool, true)
    assert(result_is_ok(result) && len(block) == 64)
    block[0] = 42
    resolved, result := pool_resolve(&pool, handle)
    assert(result_is_ok(result) && resolved[0] == 42)
    assert(result_is_ok(pool_free(&pool, handle, true)))
    _, stale := pool_resolve(&pool, handle)
    assert(stale.error == .Stale_Handle)
    assert(pool_validate(&pool))
}
