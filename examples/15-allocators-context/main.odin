package main

import (
    "core:fmt"
    "core:mem"
)

Buffer :: struct {
    allocator: mem.Allocator,
    data: [dynamic]u8,
}

init_buffer :: proc(allocator: mem.Allocator) -> Buffer {
    result: Buffer
    result.allocator = allocator
    make(&result.data, 0, 16, allocator)
    return result
}

destroy_buffer :: proc(buffer: ^Buffer) {
    delete(buffer.data)
}

main :: proc() {
    buffer := init_buffer(context.allocator)
    defer destroy_buffer(&buffer)

    append(&buffer.data, 1, 2, 3)
    fmt.println(buffer.data[:])
}
