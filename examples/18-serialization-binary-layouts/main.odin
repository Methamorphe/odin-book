package main

import "core:fmt"

put_u16_le :: proc(dst: []byte, value: u16) {
    assert(len(dst) >= 2)
    dst[0] = byte(value & 0xff)
    dst[1] = byte((value >> 8) & 0xff)
}

put_u32_le :: proc(dst: []byte, value: u32) {
    assert(len(dst) >= 4)
    dst[0] = byte(value & 0xff)
    dst[1] = byte((value >> 8) & 0xff)
    dst[2] = byte((value >> 16) & 0xff)
    dst[3] = byte((value >> 24) & 0xff)
}

main :: proc() {
    bytes: [10]byte
    bytes[0] = 'O'
    bytes[1] = 'D'
    bytes[2] = 'B'
    bytes[3] = 'K'
    put_u16_le(bytes[4:6], 1)
    put_u32_le(bytes[6:10], 42)

    fmt.println(bytes)
}
