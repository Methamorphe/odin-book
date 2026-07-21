package main

import "core:fmt"
import "core:time"

workload :: proc(values: []int) -> int {
    total := 0
    for value in values {
        total += value * value
    }
    return total
}

main :: proc() {
    values := []int{1, 2, 3, 4, 5, 6, 7, 8}

    start := time.now()
    checksum := workload(values)
    elapsed := time.since(start)

    fmt.println("checksum:", checksum)
    fmt.println("elapsed:", elapsed)
}