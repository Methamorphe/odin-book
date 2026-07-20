# Chapter 10 Solutions — Maps, Strings and Runes

[← Exercises](../exercises/10-maps-strings-runes.md) · [Chapter →](../book/10-maps-strings-runes.md)

## 1. Word frequencies

```odin
counts: map[string]int
make(&counts)
defer delete(counts)

for word in words {
    current, ok := counts[word]
    if ok { counts[word] = current + 1 }
    else { counts[word] = 1 }
}
```

## 2. Presence flag

A missing key and a stored zero both produce a zero-like value. The boolean distinguishes those states.

## 3. Deterministic output

Collect map keys into a dynamic array, sort them, then iterate the sorted keys and perform map lookups. Never serialize direct map iteration order.

## 4. Map versus sorted array

For 12 read-only entries, a sorted array may be simpler, deterministic, compact, and cache-friendly. A map becomes more attractive when mutation or frequent key lookup dominates.

## 5. Byte length

```odin
ascii := "abc"
unicode := "λ"
fmt.println(len(ascii))
fmt.println(len(unicode))
```

The second length reflects UTF-8 bytes, not one user-visible symbol.

## 6. UTF-8 slicing

`text[:3]` is safe only when byte offset 3 is a known encoding boundary. General Unicode text must be decoded or indexed through validated boundaries.

## 7. Text units

A byte is storage, a rune is a Unicode code point, and a grapheme cluster approximates one user-perceived character. One grapheme may contain multiple runes and bytes.

## 8. Ownership API

```odin
name_view :: proc(record: ^const Record) -> string
format_name :: proc(record: ^const Record, allocator: Allocator) -> string
```

Document that the first result borrows from `record`, while the second returns allocator-backed storage.

## 9. Borrowed tokens

Token lexemes may slice the original input. The input buffer must remain alive and unmoved for as long as any token uses those strings.

## 10. Interning table

Store canonical string copies in table-owned memory and map text to `String_ID :: distinct u32`. State whether entries live for a parse, level, editor session, or process. Free the whole table according to that lifetime rather than pretending IDs own strings individually.
