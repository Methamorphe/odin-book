# Chapter 18 — Serialization and Binary Layouts

[← Chapter 17: Files, Paths, and Operating-System Services](17-files-paths-os-services.md) · [Exercises](../exercises/18-serialization-binary-layouts.md) · [Chapter 19: Assertions, Diagnostics, and Logging →](19-assertions-diagnostics-logging.md)

Serialization converts in-memory values into a representation that can cross a process boundary, survive a restart, or be exchanged with another system. The difficult part is not writing bytes. It is defining a stable contract.

This chapter separates three ideas that are often confused:

- an Odin value in memory;
- the physical layout chosen by the compiler and ABI;
- a deliberately specified serialized format.

## 18.1 Memory layout is not a file format

Consider a struct:

```odin
Header :: struct {
    version: u16,
    flags:   u8,
    count:   u32,
}
```

Its in-memory representation may include padding between fields. The exact layout can depend on alignment rules, field order, target architecture, and attributes.

Writing the raw bytes of this struct directly to disk creates a hidden dependency on those rules. A stable format should instead define each field explicitly.

## 18.2 Define a wire contract first

A binary format specification should state:

- magic bytes or signature;
- format version;
- byte order;
- integer widths;
- string encoding;
- length limits;
- field order;
- optional sections;
- alignment or padding rules;
- integrity checks;
- behavior for unknown fields or versions.

The implementation follows the format, not the other way around.

## 18.3 Endianness

Multi-byte integers can be encoded in little-endian or big-endian order.

The number `0x12345678` is represented as:

```text
little endian: 78 56 34 12
big endian:    12 34 56 78
```

Never rely on host endianness for a portable format. Read and write through explicit endian conversion helpers.

## 18.4 Fixed-width types

Serialized integers should use fixed-width types such as `u16`, `u32`, and `u64`. The convenience type `int` is unsuitable for a stable external layout because its width follows the target architecture.

Choose widths from the domain and validate every conversion:

```odin
if len(items) > int(max(u32)) {
    return .Count_Too_Large
}
count := u32(len(items))
```

An explicit cast does not prove the value fits.

## 18.5 Length-prefixed data

Variable-length data is commonly encoded as a length followed by bytes:

```text
u32 byte_length
[byte_length]byte payload
```

Before allocating, validate the declared length against:

- remaining input bytes;
- a format-specific maximum;
- total memory budget;
- arithmetic overflow when computing offsets.

A malicious file may claim a four-gigabyte string even when only a few bytes remain.

## 18.6 Cursor-based parsing

A useful parser abstraction tracks an input slice and a current offset:

```odin
Reader :: struct {
    data:   []byte,
    offset: int,
}
```

Each read operation:

1. checks enough bytes remain;
2. decodes according to the format;
3. advances the cursor only on success;
4. returns a typed failure otherwise.

This centralizes bounds checking and avoids scattered pointer arithmetic.

## 18.7 Integer overflow in bounds checks

This check is unsafe when addition can overflow:

```text
offset + length <= total
```

A safer shape is:

```text
length <= total - offset
```

but only after proving `offset <= total` and that both values share a suitable unsigned or validated domain.

Parsing untrusted binary data requires reasoning about every arithmetic operation, not only the final slice access.

## 18.8 Writing with a buffer

A writer can append encoded fields to a dynamic byte array or write incrementally to a file.

Buffering first is convenient when:

- the output is small;
- a checksum covers the complete payload;
- the final size is needed before writing;
- atomic replacement is desired.

Streaming is preferable when output is large or can be produced incrementally.

Reserve expected capacity where practical to reduce reallocations.

## 18.9 Strings and text encoding

A format must define how strings are encoded. UTF-8 is often a strong default, but the format must also define:

- whether invalid UTF-8 is rejected;
- whether strings may contain zero bytes;
- whether normalization is required;
- whether lengths count bytes or code points;
- the maximum encoded length.

Lengths should usually count encoded bytes because that is what the parser consumes.

## 18.10 Floating-point values

Serializing IEEE 754 bit patterns can be appropriate when both sides agree on the representation. Still define:

- width (`f32` or `f64`);
- byte order;
- handling of NaN and infinity;
- whether exact reproducibility is required.

For business or financial data, decimal fixed-point integers may be more appropriate than binary floating point.

## 18.11 Versioning

Formats evolve. A version field lets the reader choose an interpretation:

```text
magic:   4 bytes
version: u16
flags:   u16
```

Common strategies include:

- reject unknown versions;
- migrate old versions into the current in-memory model;
- use optional tagged sections;
- preserve unknown fields for round-tripping;
- maintain separate readers per version.

Do not reinterpret an old field silently when its meaning changes. Add a new version or field.

## 18.12 Tagged formats

A tagged record can store field identifiers and lengths:

```text
field_id: u16
length:   u32
payload:  length bytes
```

This supports skipping unknown fields and adding optional data. The cost is larger files and more parsing complexity.

A tightly packed positional format may be appropriate for assets compiled together with an engine version. A tagged format is often better for long-lived user data or network evolution.

## 18.13 Checksums and integrity

Checksums detect accidental corruption. Cryptographic authentication protects against intentional modification when a secret or trusted signature is involved.

Do not confuse:

- CRC with authentication;
- hashing with encryption;
- encryption with integrity unless the construction provides authenticated encryption.

Choose the mechanism from the threat model.

## 18.14 Zero-copy views

A parser can return slices into the original input rather than allocating copies. This can be fast and memory-efficient, but every returned view is tied to the input buffer lifetime.

Document that relationship clearly:

```text
Parsed strings remain valid only while the source byte buffer is alive and unchanged.
```

Copy data that must outlive the input or survive buffer reuse.

## 18.15 Alignment and mapped files

Memory-mapped formats sometimes use aligned sections so data can be viewed directly. This requires strict control over:

- alignment;
- endian representation;
- pointer validity;
- architecture assumptions;
- format version;
- bounds checks before constructing views.

Mapped bytes are still untrusted input. Zero-copy does not remove validation.

## 18.16 JSON and textual formats

Textual serialization offers readability and tooling, but still needs a schema and limits.

When parsing JSON, define:

- required and optional fields;
- duplicate key behavior;
- unknown field behavior;
- numeric ranges;
- maximum nesting and collection sizes;
- migration policy.

Human-readable does not mean safe by default.

## 18.17 Deterministic serialization

Deterministic output is valuable for:

- content-addressed caches;
- build reproducibility;
- clean version-control diffs;
- stable tests;
- network state hashes.

Maps require special care because iteration order is not guaranteed. Sort keys before serialization when ordering affects output bytes.

Normalize optional and default fields consistently.

## 18.18 Worked example: a tiny binary header

```odin
package main

import "core:encoding/binary"
import "core:fmt"

MAGIC :: [4]byte{'O', 'D', 'B', 'K'}

Header :: struct {
    version: u16,
    count:   u32,
}

write_header :: proc(buffer: ^[10]byte, header: Header) {
    buffer[0] = MAGIC[0]
    buffer[1] = MAGIC[1]
    buffer[2] = MAGIC[2]
    buffer[3] = MAGIC[3]
    binary.little_endian.put_u16(buffer[4:6], header.version)
    binary.little_endian.put_u32(buffer[6:10], header.count)
}

main :: proc() {
    bytes: [10]byte
    write_header(&bytes, Header{version = 1, count = 42})
    fmt.println(bytes)
}
```

The format is ten explicitly defined bytes. It does not depend on `size_of(Header)` or struct padding.

## 18.19 Common mistakes

### Dumping raw structs

Compiler layout is not a durable protocol.

### Trusting declared lengths

Validate against remaining bytes and configured limits before allocating or slicing.

### Using `int` in a format

Use fixed-width types and validate conversions.

### Forgetting endianness

Pick one order and encode explicitly.

### Returning views without lifetime documentation

Zero-copy data remains borrowed from the input.

### Serializing maps in iteration order

Sort keys when deterministic bytes matter.

### Treating versioning as a future problem

Add a version and migration strategy before data becomes long-lived.

## 18.20 Chapter checklist

You should now be able to:

- distinguish in-memory layout from a serialized contract;
- define fixed widths and byte order;
- build cursor-based readers with centralized bounds checks;
- validate lengths and arithmetic before allocation;
- choose between positional, tagged, textual, and mapped formats;
- design versioned readers;
- reason about borrowed zero-copy views;
- produce deterministic serialized output.

## References

- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin `core:encoding/binary` package](https://pkg.odin-lang.org/core/encoding/binary/)
- [Odin `core:encoding/json` package](https://pkg.odin-lang.org/core/encoding/json/)
- [RFC 8259 — The JSON Data Interchange Format](https://www.rfc-editor.org/rfc/rfc8259)
