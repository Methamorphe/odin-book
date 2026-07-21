package main

import "core:fmt"

Action :: enum { Move_Left, Move_Right, Jump, Pause }
Phase :: enum { Pressed, Released }
Event :: struct { frame: u32, action: Action, phase: Phase }
Recorder :: struct { events: [128]Event, count: int, replay_at: int }

record :: proc(r: ^Recorder, event: Event) -> bool {
    if r.count >= len(r.events) { return false }
    r.events[r.count] = event
    r.count += 1
    return true
}

replay_frame :: proc(r: ^Recorder, frame: u32, output: []Event) -> int {
    count := 0
    for r.replay_at < r.count && r.events[r.replay_at].frame <= frame {
        e := r.events[r.replay_at]
        if e.frame == frame && count < len(output) {
            output[count] = e
            count += 1
        }
        r.replay_at += 1
    }
    return count
}

main :: proc() {
    recorder: Recorder
    assert(record(&recorder, {1, .Move_Right, .Pressed}))
    assert(record(&recorder, {3, .Jump, .Pressed}))
    buffer: [8]Event
    for frame: u32 = 0; frame < 5; frame += 1 {
        n := replay_frame(&recorder, frame, buffer[:])
        for e in buffer[:n] { fmt.println("frame", frame, e.action, e.phase) }
    }
}
