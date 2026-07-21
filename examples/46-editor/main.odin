package main

import "core:fmt"

Transform :: struct {
    x, y: f32,
}

Transform_Command :: struct {
    target: ^Transform,
    before: Transform,
    after: Transform,
}

apply :: proc(command: Transform_Command) {
    command.target^ = command.after
}

revert :: proc(command: Transform_Command) {
    command.target^ = command.before
}

main :: proc() {
    transform := Transform{x = 1, y = 2}
    command := Transform_Command{
        target = &transform,
        before = transform,
        after = Transform{x = 10, y = 20},
    }

    apply(command)
    fmt.println("after apply:", transform)
    revert(command)
    fmt.println("after undo:", transform)
}