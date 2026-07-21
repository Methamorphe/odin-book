package main

import "core:fmt"

Level :: enum { Debug, Info, Warn, Error }
Field :: struct { key, value: string }
Record :: struct { sequence: u64, level: Level, message: string, fields: [4]Field, field_count: int }
Logger :: struct { records: [32]Record, write: int, count: int, next_sequence: u64 }

log :: proc(l: ^Logger, level: Level, message: string, fields: []Field) {
    index := l.write
    r := &l.records[index]
    r^ = Record{sequence = l.next_sequence, level = level, message = message}
    l.next_sequence += 1
    r.field_count = min(len(fields), len(r.fields))
    copy(r.fields[:r.field_count], fields[:r.field_count])
    l.write = (l.write + 1) % len(l.records)
    l.count = min(l.count + 1, len(l.records))
}

print_records :: proc(l: ^Logger) {
    start := (l.write - l.count + len(l.records)) % len(l.records)
    for n in 0..<l.count {
        r := &l.records[(start+n)%len(l.records)]
        fmt.printf("[%d] %v %s", r.sequence, r.level, r.message)
        for f in r.fields[:r.field_count] { fmt.printf(" %s=%s", f.key, f.value) }
        fmt.println()
    }
}

main :: proc() {
    logger: Logger
    log(&logger, .Info, "startup", []Field{{"mode", "debug"}, {"backend", "headless"}})
    log(&logger, .Warn, "asset missing", []Field{{"asset", "player.mesh"}})
    print_records(&logger)
}
