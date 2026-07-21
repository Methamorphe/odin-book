# Chapter 26 Solutions — Reflection and Compile-Time Features

[← Exercises](../exercises/26-reflection-compile-time.md) · [Chapter](../book/26-reflection-compile-time.md)

1. Use a compile-time `when ODIN_OS == .Windows` branch and a fallback branch for `/`. The inactive declaration is not emitted.
2. `minimum` needs values of one type supporting `<` and return-by-value semantics. Reject types without an ordering rather than adding hidden conversion rules.
3. Use `#assert(size_of(Header) == expected)` and `#assert(align_of(Header) == expected_alignment)` near the ABI or format declaration.
4. Example tags: `min:"0" max:"100" unit:"m" editor:"readonly"`. Parse once, reject non-numeric ranges, inverted limits, unknown keys, and incompatible tags with field-qualified diagnostics.
5. Raw pointers lack ownership, unions need active-variant policy, maps need stable ordering and key rules, handles usually represent external state, caches should be excluded, and allocators must never be serialized as ordinary data.
6. Reflect once during tool initialization, validate tags, produce compact descriptors containing offsets and widget policy, then render from descriptors without repeated metadata traversal.
7. For a closed small set, overloads or a dispatch table are clearer and more explicit. Reflection is justified when behavior is structural and the set changes through data definitions.
8. Hundreds of specializations increase compile time, code size, diagnostics, and instruction-cache pressure. Share a non-polymorphic core or reduce the specialization dimensions.

## Challenge notes

Restrict the first version to validated plain fields, use explicit opt-out and rename tags, sort fields deterministically, reject unsupported types with a field path, allocate decoded ownership through a supplied allocator, and preserve fixed fixtures for old versions.