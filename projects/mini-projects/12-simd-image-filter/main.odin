package main

import "core:fmt"

Pixel :: struct { r, g, b, a: u8 }

clamp_u8 :: proc(value: i32) -> u8 {
    if value < 0 { return 0 }
    if value > 255 { return 255 }
    return u8(value)
}

brighten_scalar :: proc(pixels: []Pixel, amount: i32) {
    for &p in pixels {
        p.r = clamp_u8(i32(p.r)+amount)
        p.g = clamp_u8(i32(p.g)+amount)
        p.b = clamp_u8(i32(p.b)+amount)
    }
}

checksum :: proc(pixels: []Pixel) -> u64 {
    sum: u64
    for p in pixels { sum += u64(p.r)+u64(p.g)+u64(p.b)+u64(p.a) }
    return sum
}

main :: proc() {
    image: [8]Pixel
    for i in 0..<len(image) { image[i] = Pixel{u8(i*10), 20, 30, 255} }
    brighten_scalar(image[:], 15)
    fmt.println("checksum:", checksum(image[:]))
}
