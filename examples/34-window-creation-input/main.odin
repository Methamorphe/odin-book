package main

import "core:fmt"

Button :: enum { Move_Left, Move_Right, Jump }

Input_State :: struct {
    down: [Button]bool,
    pressed: [Button]bool,
    released: [Button]bool,
}

begin_frame :: proc(input: ^Input_State) {
    input.pressed = {}
    input.released = {}
}

set_button :: proc(input: ^Input_State, button: Button, is_down: bool) {
    was_down := input.down[button]
    input.down[button] = is_down
    input.pressed[button] = !was_down && is_down
    input.released[button] = was_down && !is_down
}

main :: proc() {
    input: Input_State
    begin_frame(&input)
    set_button(&input, .Jump, true)
    fmt.println("jump pressed:", input.pressed[.Jump])
}