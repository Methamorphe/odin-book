package main

import "core:fmt"
import "core:os"

MAX_FILE_SIZE :: 64 * 1024

main :: proc() {
    path := "settings.txt"

    data, err := os.read_entire_file(path, context.allocator)
    if err != nil {
        fmt.eprintf("could not read %q: %v\n", path, err)
        return
    }
    defer delete(data)

    if len(data) > MAX_FILE_SIZE {
        fmt.eprintf("%q exceeds the %d-byte limit\n", path, MAX_FILE_SIZE)
        return
    }

    fmt.printf("loaded %d bytes from %q\n", len(data), path)
}
