package testing_example

import "core:testing"

square :: proc(value: int) -> int {
    return value * value
}

@(test)
square_table :: proc(t: ^testing.T) {
    cases := []struct { input, expected: int }{
        {0, 0},
        {2, 4},
        {-3, 9},
    }

    for c in cases {
        testing.expect_value(t, square(c.input), c.expected)
    }
}