package main

import "core:fmt"

Job_Proc :: proc(data: rawptr)
Job :: struct { run: Job_Proc, data: rawptr }
Queue :: struct { jobs: [64]Job, read, write, count: int, accepting: bool }

init :: proc(q: ^Queue) { q.accepting = true }
submit :: proc(q: ^Queue, job: Job) -> bool {
    if !q.accepting || q.count == len(q.jobs) { return false }
    q.jobs[q.write] = job
    q.write = (q.write + 1) % len(q.jobs)
    q.count += 1
    return true
}

execute_one :: proc(q: ^Queue) -> bool {
    if q.count == 0 { return false }
    job := q.jobs[q.read]
    q.read = (q.read + 1) % len(q.jobs)
    q.count -= 1
    job.run(job.data)
    return true
}

drain :: proc(q: ^Queue) { for execute_one(q) {} }
shutdown :: proc(q: ^Queue) { q.accepting = false; drain(q) }

increment :: proc(data: rawptr) { value := cast(^int)data; value^ += 1 }

main :: proc() {
    q: Queue
    init(&q)
    value := 0
    for _ in 0..<10 { assert(submit(&q, Job{increment, &value})) }
    shutdown(&q)
    assert(value == 10 && q.count == 0)
    fmt.println("completed jobs:", value)
}
