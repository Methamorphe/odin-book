package main

import "core:fmt"

foreign import libc "system:c"

foreign libc {
    strlen :: proc "c" (text: cstring) -> uintptr ---
}

safe_strlen :: proc(text: string) -> (int, bool) {
    if len(text) == 0 { return 0, true }
    c_text := transmute(cstring)raw_data(text)
    return int(strlen(c_text)), true
}

main :: proc() {
    n, ok := safe_strlen("odin")
    assert(ok && n == 4)
    fmt.println("length:", n)
}
