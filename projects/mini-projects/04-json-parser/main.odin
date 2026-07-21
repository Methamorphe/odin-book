package main

import "core:fmt"

Kind :: enum { Null, Bool, Number, String, Array, Object }
Token :: struct { kind: Kind, text: string }
Parser :: struct { source: string, at: int }

skip_ws :: proc(p: ^Parser) {
    for p.at < len(p.source) {
        c := p.source[p.at]
        if c != ' ' && c != '\n' && c != '\r' && c != '\t' { break }
        p.at += 1
    }
}

parse_string :: proc(p: ^Parser) -> (Token, bool) {
    skip_ws(p)
    if p.at >= len(p.source) || p.source[p.at] != '"' { return {}, false }
    start := p.at + 1
    p.at = start
    for p.at < len(p.source) && p.source[p.at] != '"' {
        if p.source[p.at] == '\\' { p.at += 1 }
        p.at += 1
    }
    if p.at >= len(p.source) { return {}, false }
    text := p.source[start:p.at]
    p.at += 1
    return Token{.String, text}, true
}

parse_number :: proc(p: ^Parser) -> (Token, bool) {
    skip_ws(p)
    start := p.at
    if p.at < len(p.source) && p.source[p.at] == '-' { p.at += 1 }
    digits := 0
    for p.at < len(p.source) && p.source[p.at] >= '0' && p.source[p.at] <= '9' {
        p.at += 1
        digits += 1
    }
    if digits == 0 { p.at = start; return {}, false }
    return Token{.Number, p.source[start:p.at]}, true
}

main :: proc() {
    parser := Parser{source = `"odin" 123 -7`}
    a, ok := parse_string(&parser)
    assert(ok && a.text == "odin")
    b, ok := parse_number(&parser)
    assert(ok && b.text == "123")
    c, ok := parse_number(&parser)
    assert(ok && c.text == "-7")
    fmt.println(a.kind, a.text, b.text, c.text)
}
