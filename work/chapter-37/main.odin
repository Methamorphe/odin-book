package main

import "core:fmt"
import "core:testing"

CHAPTER :: 37

execute_line :: proc(line: string) -> bool {
    if line == "quit" { return false }
    return true
}

main :: proc() {
    fmt.printf("Chapter %02d interactive workshop\n", CHAPTER)
    fmt.println("Open exercises/INTERACTIVE_WORKBOOK.md and implement this chapter's commands.")
}

@(test)
scaffold_starts :: proc(t: ^testing.T) { testing.expect(t, execute_line("help")) }

@(test)
quit_stops :: proc(t: ^testing.T) { testing.expect(t, !execute_line("quit")) }
