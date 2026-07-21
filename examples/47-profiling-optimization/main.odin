package main

import "core:fmt"

Frame_Stats :: struct {
    samples: [8]f64,
    count: int,
}

push_sample :: proc(stats: ^Frame_Stats, milliseconds: f64) {
    if stats.count < len(stats.samples) {
        stats.samples[stats.count] = milliseconds
        stats.count += 1
    }
}

average :: proc(stats: Frame_Stats) -> f64 {
    if stats.count == 0 {
        return 0
    }
    total: f64
    for i in 0..<stats.count {
        total += stats.samples[i]
    }
    return total / f64(stats.count)
}

worst :: proc(stats: Frame_Stats) -> f64 {
    result: f64
    for i in 0..<stats.count {
        if stats.samples[i] > result {
            result = stats.samples[i]
        }
    }
    return result
}

main :: proc() {
    stats: Frame_Stats
    push_sample(&stats, 15.8)
    push_sample(&stats, 16.2)
    push_sample(&stats, 24.7)
    fmt.println("average ms:", average(stats))
    fmt.println("worst ms:", worst(stats))
}