package main

import "core:fmt"

Platform_Event_Kind :: enum { None, Window_Closed, Key_Pressed, Key_Released }

Platform_Event :: struct {
    kind: Platform_Event_Kind,
    key: u32,
}

process_event :: proc(event: Platform_Event, running: ^bool) {
    switch event.kind {
    case .Window_Closed:
        running^ = false
    case .Key_Pressed:
        fmt.println("key pressed:", event.key)
    case .Key_Released:
        fmt.println("key released:", event.key)
    case .None:
    }
}

main :: proc() {
    running := true
    events := []Platform_Event{
        {kind = .Key_Pressed, key = 32},
        {kind = .Key_Released, key = 32},
        {kind = .Window_Closed},
    }
    for event in events {
        process_event(event, &running)
    }
    fmt.println("running:", running)
}