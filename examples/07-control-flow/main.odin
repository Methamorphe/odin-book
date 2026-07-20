package main

import "core:fmt"

main :: proc() {
    commands := []string{"status", "start", "status", "stop"}
    running := false

    for command, index in commands {
        fmt.printf("[%d] %s: ", index, command)
        switch command {
        case "start":
            if running { fmt.println("already running"); continue }
            running = true
            fmt.println("started")
        case "stop":
            if !running { fmt.println("already stopped"); continue }
            running = false
            fmt.println("stopped")
        case "status":
            if running { fmt.println("running") } else { fmt.println("stopped") }
        case:
            fmt.println("unknown")
        }
    }
}
