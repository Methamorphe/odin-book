package main

import "core:fmt"
import "core:simd"

Vec4 :: #simd[4]f32

main :: proc() {
    a := Vec4{1, 2, 3, 4}
    b := Vec4{5, 6, 7, 8}
    product := a * b

    dot := simd.extract(product, 0) +
           simd.extract(product, 1) +
           simd.extract(product, 2) +
           simd.extract(product, 3)
    fmt.println("dot product:", dot)
}
