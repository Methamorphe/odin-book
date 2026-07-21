package main

import "core:fmt"
import "core:time"

Sample :: struct { name: string, elapsed: time.Duration }
Profiler :: struct { samples: [64]Sample, count: int }

measure :: proc(p: ^Profiler, name: string, work: proc()) {
    start := time.now()
    work()
    if p.count < len(p.samples) {
        p.samples[p.count] = Sample{name, time.since(start)}
        p.count += 1
    }
}

busy_work :: proc() {
    sum: u64
    for i in 0..<100_000 { sum += u64(i*i) }
    assert(sum > 0)
}

main :: proc() {
    profiler: Profiler
    measure(&profiler, "busy_work", busy_work)
    for sample in profiler.samples[:profiler.count] {
        fmt.println(sample.name, sample.elapsed)
    }
}
