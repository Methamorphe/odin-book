package main

import "core:fmt"

Header :: struct { magic: [4]u8, version: u16, count: u16 }
Record :: struct { id: u32, value: i32 }
Archive :: struct { header: Header, records: [16]Record }

checksum :: proc(a: ^Archive) -> u64 {
    sum: u64
    for r in a.records[:a.header.count] {
        sum = sum*1099511628211 + u64(r.id) + u64(u32(r.value))
    }
    return sum
}

validate :: proc(a: ^Archive) -> bool {
    return a.header.magic == [4]u8{'O','D','A','R'} && a.header.version == 1 && int(a.header.count) <= len(a.records)
}

main :: proc() {
    archive := Archive{header = Header{magic = {'O','D','A','R'}, version = 1, count = 2}}
    archive.records[0] = Record{1, 42}
    archive.records[1] = Record{2, -7}
    assert(validate(&archive))
    fmt.println("records:", archive.header.count, "checksum:", checksum(&archive))
}
