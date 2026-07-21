package main

import "core:fmt"

Audio_Event_Kind :: enum { Play, Stop, Set_Gain }

Audio_Event :: struct {
    kind: Audio_Event_Kind,
    voice: u32,
    value: f32,
}

process_event :: proc(event: Audio_Event) {
    switch event.kind {
    case .Play:
        fmt.println("play voice", event.voice)
    case .Stop:
        fmt.println("stop voice", event.voice)
    case .Set_Gain:
        fmt.println("gain", event.voice, event.value)
    }
}

main :: proc() {
    events := []Audio_Event{
        {kind = .Play, voice = 1},
        {kind = .Set_Gain, voice = 1, value = 0.5},
        {kind = .Stop, voice = 1},
    }
    for event in events {
        process_event(event)
    }
}