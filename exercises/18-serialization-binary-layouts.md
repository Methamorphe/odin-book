# Chapter 18 Exercises — Serialization and Binary Layouts

[← Chapter](../book/18-serialization-binary-layouts.md) · [Solutions](../solutions/18-serialization-binary-layouts.md)

## Exercise 1 — Specify a header

Design a binary header containing four magic bytes, a `u16` version, a `u16` flags field, and a `u32` record count. State byte order and total encoded size.

## Exercise 2 — Cursor reader

Implement a reader with `data` and `offset`, plus safe procedures for reading `u8`, little-endian `u16`, and little-endian `u32`.

## Exercise 3 — Length-prefixed string

Read a `u32` byte length followed by UTF-8 bytes. Reject lengths above 1 MiB, lengths beyond remaining input, and invalid UTF-8.

## Exercise 4 — Overflow audit

Explain why `offset + length <= len(data)` can be unsafe. Rewrite the validation with ordered checks that cannot overflow.

## Exercise 5 — Deterministic map output

Serialize a `map[string]u32` deterministically. Define how keys are ordered and how each entry is encoded.

## Exercise 6 — Version migration

Version 1 stores `name`; version 2 stores `display_name` and `slug`. Design a reader that converts both versions into one current in-memory struct.

## Exercise 7 — Borrowed views

Create a parser that returns slices into the source buffer. Document the lifetime contract and identify when copies are required.

## Challenge — Asset index format

Specify and implement a versioned asset index containing paths, content hashes, byte sizes, and dependency IDs. Include corruption checks, limits, deterministic writing, and unknown-version behavior.
