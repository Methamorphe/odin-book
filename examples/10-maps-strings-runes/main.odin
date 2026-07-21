package main

import "core:fmt"

main :: proc() {
    words := []string{"odin", "systems", "odin", "data", "systems", "odin"}

    counts := make(map[string]int)
    defer delete(counts)

    for word in words {
        current, ok := counts[word]
        if ok {
            counts[word] = current + 1
        } else {
            counts[word] = 1
        }
    }

    for word, count in counts {
        fmt.printf("%s: %d\n", word, count)
    }
}
