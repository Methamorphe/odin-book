package main

import "core:fmt"

minimum :: proc(a, b: $T) -> T {
    if a < b do return a
    return b
}

main :: proc() {
    when ODIN_OS == .Windows {
        fmt.println("path separator: \\")
    } else {
        fmt.println("path separator: /")
    }

    fmt.println("minimum:", minimum(42, 17))
}