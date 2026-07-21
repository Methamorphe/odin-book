# Chapter 26 Exercises — Reflection and Compile-Time Features

[← Chapter](../book/26-reflection-compile-time.md) · [Solutions](../solutions/26-reflection-compile-time.md)

1. Use `when` to choose one path separator constant for Windows and another for Unix-like targets.
2. Write a polymorphic `minimum` procedure and identify which operations its type must support.
3. Add compile-time assertions for the size and alignment of a binary header.
4. Design a tag convention for editor ranges, units, and read-only fields. Define malformed-tag diagnostics.
5. List fields that a generic serializer must reject or require policy for: pointers, unions, maps, handles, cached values, and allocators.
6. Design a reflected property inspector that converts metadata into cached descriptors during initialization.
7. Compare reflection, overloads, and a dispatch table for a closed set of five message types.
8. Identify compile-time and binary-size risks in a polymorphic helper instantiated for hundreds of types.

## Challenge

Design a versioned reflected serializer for plain data structs. Include field naming, opt-out tags, unsupported-type errors, deterministic ordering, allocator policy, and compatibility tests.