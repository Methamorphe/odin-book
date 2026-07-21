package main

import "core:fmt"

Vec4 :: #simd[4]f32

main :: proc() {
    a := Vec4{1, 2, 3, 4}
    b := Vec4{5, 6, 7, 8}
    product := a * b

    dot := product[0] + product[1] + product[2] + product[3]
    fmt.println("dot product:", dot)
}