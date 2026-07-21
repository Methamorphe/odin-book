package main

import "core:fmt"

Command_Kind :: enum { Set_X, Set_Y }
Command :: struct { kind: Command_Kind, before, after: f32 }
Object :: struct { x, y: f32 }
History :: struct { commands: [64]Command, count, cursor: int }

apply :: proc(object: ^Object, command: Command, forward: bool) {
    value := forward ? command.after : command.before
    switch command.kind {
    case .Set_X: object.x = value
    case .Set_Y: object.y = value
    }
}

execute :: proc(h: ^History, object: ^Object, command: Command) -> bool {
    if h.cursor >= len(h.commands) { return false }
    h.commands[h.cursor] = command
    h.cursor += 1
    h.count = h.cursor
    apply(object, command, true)
    return true
}

undo :: proc(h: ^History, object: ^Object) -> bool {
    if h.cursor == 0 { return false }
    h.cursor -= 1
    apply(object, h.commands[h.cursor], false)
    return true
}

redo :: proc(h: ^History, object: ^Object) -> bool {
    if h.cursor >= h.count { return false }
    apply(object, h.commands[h.cursor], true)
    h.cursor += 1
    return true
}

main :: proc() {
    object: Object
    history: History
    assert(execute(&history, &object, {.Set_X, 0, 12}))
    assert(execute(&history, &object, {.Set_Y, 0, -4}))
    assert(undo(&history, &object) && object.y == 0)
    assert(redo(&history, &object) && object.y == -4)
    fmt.println(object)
}
