package main

import "core:fmt"

Artifact_Header :: struct {
    magic: u32,
    asset_type: u16,
    version: u16,
    payload_size: u32,
}

VALID_MAGIC :: u32(0x4f44494e)

validate_header :: proc(header: Artifact_Header, available_bytes: int) -> bool {
    if header.magic != VALID_MAGIC {
        return false
    }
    if header.version != 1 {
        return false
    }
    return int(header.payload_size) <= available_bytes
}

main :: proc() {
    header := Artifact_Header{
        magic = VALID_MAGIC,
        asset_type = 3,
        version = 1,
        payload_size = 128,
    }
    fmt.println("valid artifact:", validate_header(header, 128))
}