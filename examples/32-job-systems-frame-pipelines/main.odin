package main

import "core:fmt"

Job :: struct {
    start, end: int,
}

run_job :: proc(values: []int, job: Job) {
    for i in job.start..<job.end {
        values[i] = values[i] * values[i]
    }
}

main :: proc() {
    values := [12]int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
    jobs := [3]Job{
        Job{start = 0, end = 4},
        Job{start = 4, end = 8},
        Job{start = 8, end = 12},
    }

    // A real scheduler may run these jobs concurrently because their write
    // ranges do not overlap. This example keeps execution deterministic.
    for job in jobs {
        run_job(values[:], job)
    }

    fmt.println(values)
}
