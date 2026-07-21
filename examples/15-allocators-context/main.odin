package main

import "core:fmt"
import "core:mem"

Buffer :: struct {
    allocator: mem.Allocator,
    data: [dynamic]u8,
}

init_buffer :: proc(allocator: mem.Allocator) -> Buffer {
    result: Buffer
    result.allocator = allocator
    result.data = make([dynamic]u8, 0, 16, allocator) or_else panic("could not allocate buffer")
    return result
}

destroy_buffer :: proc(buffer: ^Buffer) {
    delete(buffer.data)
}

main :: proc() {
    buffer := init_buffer(context.allocator)
    defer destroy_buffer(&buffer)

    append(&buffer.data, 1, 2, 3) or_else panic("could not append to buffer")
    fmt.println(buffer.data[:])
}
