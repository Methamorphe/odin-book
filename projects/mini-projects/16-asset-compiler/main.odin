package main

import "core:fmt"

Artifact_Header :: struct { magic: [4]u8, schema: u16, importer: u16, source_hash: u64, payload_size: u32 }
Source :: struct { path: string, bytes: []u8 }
Artifact :: struct { header: Artifact_Header, payload: [256]u8 }

hash_bytes :: proc(bytes: []u8) -> u64 {
    h: u64 = 1469598103934665603
    for b in bytes { h = (h ^ u64(b))*1099511628211 }
    return h
}

compile_uppercase :: proc(source: Source) -> (Artifact, bool) {
    if len(source.bytes) > 256 { return {}, false }
    result := Artifact{header = Artifact_Header{magic = {'O','D','A','F'}, schema = 1, importer = 1, source_hash = hash_bytes(source.bytes), payload_size = u32(len(source.bytes))}}
    for b, i in source.bytes {
        result.payload[i] = b >= 'a' && b <= 'z' ? b-32 : b
    }
    return result, true
}

main :: proc() {
    bytes := []u8{'h','e','r','o'}
    artifact, ok := compile_uppercase(Source{"hero.txt", bytes})
    assert(ok)
    fmt.println("hash:", artifact.header.source_hash, "size:", artifact.header.payload_size)
}
