# Chapter 10 — Maps, Strings and Runes

[← Chapter 9: Arrays, Slices and Dynamic Arrays](09-arrays-slices-dynamic-arrays.md) · [Exercises](../exercises/10-maps-strings-runes.md) · [Chapter 11: Structs, Enums and Unions →](11-structs-enums-unions.md)

Maps and strings solve common problems, but both carry representation and lifetime rules that systems programmers must understand. A map provides key-based lookup through allocator-backed storage. A string is an immutable view over bytes, not a growable text object. Unicode introduces another layer: bytes, code points, and user-perceived characters are not the same thing.

## 10.1 Maps

A map associates keys with values:

```odin
scores: map[string]int
scores["Ada"] = 100
scores["Grace"] = 95
```

Maps are useful when lookup by key matters more than contiguous iteration or compact layout.

## 10.2 Map lifetime

Maps own allocator-backed storage and must be released:

```odin
scores: map[string]int
make(&scores)
defer delete(scores)
```

Use the allocator and initialization form appropriate to the current Odin version and project conventions. The essential rule is stable: map storage has an owner and a lifetime.

## 10.3 Lookup with presence

A missing key must not be confused with a stored zero value:

```odin
score, ok := scores["Ada"]
if ok {
    fmt.println(score)
}
```

This is important because `0`, `false`, an empty string, or a zeroed struct may be valid stored values.

## 10.4 Insertion and update

Assignment through a key inserts or replaces:

```odin
scores["Ada"] = 100
scores["Ada"] = 101
```

When updates depend on the previous value, perform the lookup explicitly:

```odin
count, ok := counts[word]
if ok {
    counts[word] = count + 1
} else {
    counts[word] = 1
}
```

## 10.5 Removing entries

Map deletion should be explicit. After removal, any assumptions about references to internal map storage must be reconsidered. Treat map values as retrieved data rather than stable addresses unless the API explicitly guarantees otherwise.

## 10.6 Iteration order

Do not rely on map iteration order. If output must be deterministic, collect keys into a separate array, sort them, and then perform lookups in that order.

Determinism matters for:

- tests;
- serialized output;
- build tools;
- network protocols;
- reproducible asset pipelines.

## 10.7 Choosing a map key

Good keys have stable equality and hashing behavior. Common choices include:

- integers and distinct IDs;
- strings whose lifetime is well understood;
- enums;
- compact value types with clear equality.

Avoid mutable key data or keys that retain references to temporary storage.

## 10.8 Maps versus sorted arrays

A map is not always the best lookup structure. For small collections or read-mostly data, a sorted array may offer:

- lower memory overhead;
- deterministic order;
- better cache locality;
- simpler serialization.

Choose based on collection size, mutation rate, lookup frequency, and iteration patterns.

## 10.9 Strings are immutable byte views

```odin
message: string = "Hello, Odin"
```

A string conceptually contains a pointer and a byte length. It does not own a growable character buffer and cannot be modified in place.

Consequences:

- `len(message)` reports bytes;
- indexing addresses bytes;
- slicing creates another view;
- lifetime follows the backing storage;
- text construction usually requires a builder, byte buffer, or formatting operation.

## 10.10 String equality

String equality compares content rather than only pointer identity:

```odin
if command == "start" {
    // ...
}
```

For repeated case-insensitive or normalized comparisons, preprocess data according to domain rules rather than repeatedly allocating transformed strings.

## 10.11 String slicing

```odin
prefix := message[:5]
```

String slicing works in byte offsets. This is safe for ASCII boundaries but can split a multi-byte UTF-8 encoding if used blindly on general Unicode text.

Byte slicing is appropriate for:

- protocol tokens defined in ASCII;
- file signatures;
- known UTF-8 boundaries;
- parsers that deliberately operate on bytes.

## 10.12 Bytes, runes, and graphemes

Three different units matter:

1. **byte** — an 8-bit storage unit;
2. **rune** — a Unicode code point;
3. **grapheme cluster** — what a user often perceives as one character.

The text `é` may be encoded as one precomposed code point or as `e` plus a combining accent. Both can look identical while having different byte and rune sequences.

User-facing text operations such as cursor movement, truncation, or character counts may require grapheme-aware libraries, not just rune iteration.

## 10.13 Iterating UTF-8 text

Rune-aware iteration decodes code points rather than treating each byte as a character. Keep invalid UTF-8 behavior explicit when reading external data: reject, replace, preserve raw bytes, or report an error according to the domain.

Do not assume every file or network payload is valid UTF-8 merely because the destination type is text-oriented.

## 10.14 String ownership

A string may refer to:

- static program data;
- memory owned by another collection;
- allocator-backed formatted output;
- a file buffer;
- temporary memory.

Document whether a procedure returns a borrowed view or newly allocated text. A useful naming and API distinction is:

```odin
name_view :: proc(record: ^const Record) -> string
format_name :: proc(record: ^const Record, allocator: Allocator) -> string
```

The first borrows. The second allocates and transfers cleanup responsibility according to the package contract.

## 10.15 Constructing strings

Repeated string concatenation can cause repeated allocation and copying. For incremental output, prefer:

- a byte-oriented builder;
- a reusable buffer;
- a formatting package writing to a destination;
- a pre-sized allocation when final length is known.

For small diagnostics, convenience formatting is usually fine. For parsers, generators, logging systems, or frame loops, allocation behavior should be measured.

## 10.16 Converting between strings and bytes

Conversions between text and mutable bytes must respect ownership. A string view over a mutable buffer becomes invalid if the buffer is freed or reallocated. A copied byte array has independent storage but costs allocation and copying.

Ask three questions:

1. Who owns the bytes?
2. How long must the view remain valid?
3. Can the underlying storage move or change?

## 10.17 String interning

Interning stores one canonical copy of repeated strings and represents them with IDs or stable references. It can improve equality checks and reduce duplication in:

- compilers;
- asset registries;
- editors;
- scene data;
- configuration systems.

Interning also creates a lifetime policy: the table may live for a compilation, level, session, or process. Make that lifetime explicit.

## 10.18 Parsing without unnecessary allocation

Many parsers can operate on slices of the original input:

```odin
Token :: struct {
    kind: Token_Kind,
    lexeme: string,
}
```

Here `lexeme` borrows from the input buffer. This is efficient, but the token list cannot outlive that buffer. If tokens must persist, copy or intern the relevant text.

## 10.19 Common mistakes

### Treating string length as character count

UTF-8 uses variable-length encoding. Byte length is not a reliable user-visible count.

### Returning a view into temporary memory

The string may look valid during tests and later become corrupted. Tie views to clearly owned storage.

### Depending on map order

Always create an ordered representation when deterministic output matters.

### Using a map for every association

Small sorted arrays, enums, direct indexing, or dense handle tables may be simpler and faster.

### Allocating during every text operation

Track where formatting, concatenation, normalization, and conversion allocate.

## 10.20 Worked example: word frequencies

```odin
package main

import "core:fmt"

main :: proc() {
    words := []string{"odin", "systems", "odin", "data", "systems", "odin"}

    counts: map[string]int
    make(&counts)
    defer delete(counts)

    for word in words {
        count, ok := counts[word]
        if ok {
            counts[word] = count + 1
        } else {
            counts[word] = 1
        }
    }

    for word, count in counts {
        fmt.printf("%s: %d\n", word, count)
    }
}
```

The example is intentionally small. Production code should decide whether input strings are borrowed, copied, or interned and should sort keys when deterministic output is required.

## Chapter summary

- Maps provide key-based lookup through owned allocator-backed storage.
- Lookup should distinguish absence from a stored zero value.
- Map iteration order is not a serialization or display contract.
- Strings are immutable byte views, not growable character objects.
- Bytes, runes, and grapheme clusters represent different text units.
- String lifetime follows the backing storage.
- Parsing can avoid allocation by borrowing input slices, but ownership must remain valid.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Unicode Standard](https://www.unicode.org/standard/standard.html)
- [UTF-8, RFC 3629](https://www.rfc-editor.org/rfc/rfc3629)

[Exercises →](../exercises/10-maps-strings-runes.md) · [Back to summary](../SUMMARY.md)
