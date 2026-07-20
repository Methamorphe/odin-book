package main

import "core:fmt"

Operation :: proc(int, int) -> int

add :: proc(a, b: int) -> int { return a + b }
multiply :: proc(a, b: int) -> int { return a * b }

apply :: proc(operation: Operation, a, b: int) -> int {
    return operation(a, b)
}

safe_divide :: proc(a, b: int) -> (value: int, ok: bool) {
    if b == 0 { return 0, false }
    return a / b, true
}

main :: proc() {
    fmt.println(apply(add, 20, 22))
    fmt.println(apply(multiply, 6, 7))

    value, ok := safe_divide(84, 2)
    if ok { fmt.println(value) }
}
