package main

import "core:fmt"
import "project:arithmetic"

main :: proc() {
    fmt.println(arithmetic.add(20, 22))
}
