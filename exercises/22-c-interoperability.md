# Chapter 22 Exercises — C Interoperability

[← Chapter](../book/22-c-interoperability.md) · [Solutions](../solutions/22-c-interoperability.md)

1. Translate a C procedure taking `const uint8_t *data, size_t length` into an Odin foreign declaration.
2. Explain why an Odin `string` cannot be passed directly where a retained `const char *` is expected.
3. Translate a C struct containing `int32_t x`, `double weight`, and `void *user`, then list the layout assumptions to verify.
4. Design an opaque database handle with create, query, and destroy wrappers.
5. Translate a C callback receiving `void *user` and an integer event. Define the user-data lifetime.
6. Convert a raw integer status code into a domain `enum` while preserving the original code for diagnostics.
7. Identify which header constructs require a shim: macro, `static inline`, C++ overload, bitfield, or ordinary external function.
8. Design an Odin-to-C exported API for loading a resource through an opaque handle and explicit result code.

## Challenge

Write a binding plan for a small image library. Include raw declarations, safe wrapper, allocator policy, string conversions, repeated create/destroy tests, and target-specific linkage.