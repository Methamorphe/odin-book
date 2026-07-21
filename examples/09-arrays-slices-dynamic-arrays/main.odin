package main

import "core:fmt"

sum :: proc(values: []int) -> int {
    total := 0
    for value in values {
        total += value
    }
    return total
}

main :: proc() {
    fixed := [5]int{1, 2, 3, 4, 5}
    fmt.println("slice sum:", sum(fixed[1:4]))

    numbers := make([dynamic]int, 0, 8) or_else panic("could not allocate dynamic array")
    defer delete(numbers)

    for value in fixed {
        _ = append(&numbers, value * 10) or_else panic("could not grow dynamic array")
    }
    fmt.println("dynamic sum:", sum(numbers[:]))
}
