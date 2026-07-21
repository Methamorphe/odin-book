# Chapter 22 Solutions — C Interoperability

[← Exercises](../exercises/22-c-interoperability.md) · [Chapter](../book/22-c-interoperability.md)

1. Use `^u8` or a const-compatible pointer plus `c.size_t`; document that the pointer is borrowed for the call and convert the slice length only after checking range.
2. Odin strings carry pointer and length, may contain embedded zeros, and are not guaranteed to end with a null byte. A retained C pointer also needs storage that outlives the call.
3. Use `c.int32_t` or the binding’s exact fixed-width type, `f64` for C `double`, and `rawptr` for `void *`. Verify size, alignment, field offsets, target ABI, and packing directives.
4. Keep the foreign struct incomplete, expose an opaque pointer, translate creation errors immediately, and pair every successful creation with one destroy operation.
5. The trampoline uses the expected calling convention, converts `rawptr` in one place, and accesses state stored at a stable address until deregistration and all in-flight callbacks are complete.
6. Return a wrapper result containing the domain error and raw code. Callers branch on the domain value while logs can retain vendor detail.
7. Ordinary external functions bind directly. Macros, missing-symbol inline functions, C++ overloads, and fragile bitfields usually need translation or a C shim.
8. Export C-compatible procedures using fixed-width integers, pointer-plus-length buffers, opaque handles, explicit create/destroy, and integer result codes. Do not expose Odin slices or allocator internals.

## Challenge notes

The plan should pin the library version, isolate raw declarations, define who frees decoded pixels, test empty and malformed images, centralize platform library names, and verify packaging on clean systems.