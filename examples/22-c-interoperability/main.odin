package main

import "core:c"
import "core:fmt"

foreign import libc "system:c"

foreign libc {
    puts :: proc(message: cstring) -> c.int ---
}

main :: proc() {
    result := puts("Hello from Odin through C")
    fmt.println("puts result:", result)
}