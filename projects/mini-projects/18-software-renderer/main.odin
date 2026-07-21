package main

import "core:fmt"

Colour :: struct { r, g, b: u8 }
Image :: struct { pixels: [64*64]Colour }
Rect_Command :: struct { x, y, width, height: int, colour: Colour }

clear :: proc(image: ^Image, colour: Colour) {
    for &pixel in image.pixels { pixel = colour }
}

draw_rect :: proc(image: ^Image, command: Rect_Command) {
    x0 := clamp(command.x, 0, 64)
    y0 := clamp(command.y, 0, 64)
    x1 := clamp(command.x+command.width, 0, 64)
    y1 := clamp(command.y+command.height, 0, 64)
    for y in y0..<y1 {
        for x in x0..<x1 { image.pixels[y*64+x] = command.colour }
    }
}

checksum :: proc(image: ^Image) -> u64 {
    sum: u64
    for p in image.pixels { sum = sum*131 + u64(p.r)+u64(p.g)*3+u64(p.b)*7 }
    return sum
}

main :: proc() {
    image: Image
    clear(&image, {20, 24, 32})
    commands := [?]Rect_Command{{4, 5, 20, 10, {255, 80, 40}}, {18, 20, 30, 25, {60, 180, 255}}}
    for command in commands { draw_rect(&image, command) }
    fmt.println("render checksum:", checksum(&image))
}
