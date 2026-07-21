package main

import "core:fmt"

Entry :: struct { key: u64, value: i64, occupied: bool }
Map :: struct { entries: [64]Entry, count: int }

hash :: proc(key: u64) -> u64 {
    x := key
    x ^= x >> 33
    x *= 0xff51afd7ed558ccd
    x ^= x >> 33
    return x
}

put :: proc(m: ^Map, key: u64, value: i64) -> bool {
    start := int(hash(key) % u64(len(m.entries)))
    for probe in 0..<len(m.entries) {
        index := (start + probe) % len(m.entries)
        e := &m.entries[index]
        if !e.occupied || e.key == key {
            if !e.occupied { m.count += 1 }
            e^ = Entry{key = key, value = value, occupied = true}
            return true
        }
    }
    return false
}

get :: proc(m: ^Map, key: u64) -> (i64, bool) {
    start := int(hash(key) % u64(len(m.entries)))
    for probe in 0..<len(m.entries) {
        e := &m.entries[(start + probe) % len(m.entries)]
        if !e.occupied { return 0, false }
        if e.key == key { return e.value, true }
    }
    return 0, false
}

main :: proc() {
    m: Map
    assert(put(&m, 10, 100))
    assert(put(&m, 74, 200))
    value, found := get(&m, 74)
    assert(found && value == 200)
    fmt.println("entries:", m.count, "value:", value)
}
