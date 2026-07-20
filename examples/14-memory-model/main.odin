package main

import "core:fmt"

main :: proc() {
    values := []int{1, 2, 3}
    view := values

    view[0] = 99
    fmt.println("values:", values)
    fmt.println("view:", view)
    fmt.println("copying a slice copies its descriptor, not its elements")
}
