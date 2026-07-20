package main

import "core:fmt"

sum :: proc(values: []const int) -> int {
    total := 0
    for value in values { total += value }
    return total
}

main :: proc() {
    fixed := [5]int{1, 2, 3, 4, 5}
    fmt.println("slice sum:", sum(fixed[1:4]))

    numbers: [dynamic]int
    defer delete(numbers)
    reserve(&numbers, 8)

    for value in fixed { append(&numbers, value * 10) }
    fmt.println("dynamic sum:", sum(numbers[:]))
}
