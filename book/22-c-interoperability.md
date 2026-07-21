# Chapter 22 — C Interoperability

[← Chapter 21: Debugging and Profiling](21-debugging-profiling.md) · [Exercises](../exercises/22-c-interoperability.md) · [Chapter 23: Foreign Libraries and Bindings →](23-foreign-libraries-bindings.md)

Odin was designed to cooperate with C. That makes decades of operating-system APIs, graphics libraries, database clients, codecs, and device SDKs available without forcing them into an object-oriented wrapper model.

Interop is straightforward only when the ABI contract is understood precisely.

## 22.1 The ABI is the real contract

A header describes declarations, but the application binary interface determines how code actually communicates:

- calling convention;
- symbol names;
- integer widths;
- struct layout and alignment;
- enum representation;
- pointer ownership;
- variadic arguments;
- thread and callback rules.

Two declarations that look similar can still be incompatible at runtime.

## 22.2 Foreign imports

A foreign block declares externally implemented procedures:

```odin
foreign import libc "system:c"

foreign libc {
    puts :: proc(message: cstring) -> c.int ---
}
```

The trailing `---` marks a foreign procedure body. The exact library declaration varies by target and build setup, so keep platform-specific linkage centralized.

## 22.3 C-compatible types

Use the C type family from `core:c` when an ABI explicitly requires C widths or conventions:

```odin
import "core:c"

foreign some_lib {
    library_version :: proc() -> c.int ---
}
```

Do not assume Odin `int` is always interchangeable with C `int`. Likewise, `bool`, enums, and characters may have library-specific representation rules.

## 22.4 C strings

C strings are null-terminated byte sequences. Odin `string` is a pointer-plus-length view and is not automatically null terminated.

```odin
message: cstring = "hello"
```

When converting dynamically created Odin text, establish:

- who allocates the null-terminated buffer;
- how long it remains alive;
- whether embedded null bytes are legal;
- who frees returned C strings.

Never return a pointer to temporary storage that expires when the procedure returns.

## 22.5 Struct layout

Foreign structs must match C field order, widths, alignment, and packing. Avoid casually reproducing platform-dependent C structs from memory. Translate the authoritative header and verify sizes where practical.

```odin
C_Point :: struct {
    x: c.int,
    y: c.int,
}
```

Bitfields, flexible array members, anonymous unions, and compiler-specific packing deserve special treatment. Often the safest design is to expose accessor functions from a tiny C shim instead of duplicating an unstable layout.

## 22.6 Opaque handles

Many C libraries expose incomplete structs through pointers. Preserve that opacity:

```odin
Database :: struct {}
Database_Handle :: ^Database
```

Application code should not inspect hidden fields. Wrap creation and destruction so ownership is obvious.

## 22.7 Ownership boundaries

For every pointer crossing the boundary, document:

- borrowed or owned;
- mutable or read-only;
- length and element type;
- required alignment;
- lifetime;
- matching release function;
- whether the pointer may be retained after the call.

An ABI-correct declaration can still leak or use freed memory if ownership is wrong.

## 22.8 Arrays and buffers

C usually represents arrays as pointer-plus-count pairs. Keep them paired in the Odin wrapper:

```odin
foreign api {
    process_bytes :: proc(data: ^u8, count: c.size_t) -> c.int ---
}
```

Before passing a slice, handle the empty case according to the library contract and convert lengths only after checking representability.

## 22.9 Callbacks

Callbacks combine calling convention, lifetime, and concurrency concerns. The callback procedure must use the expected convention and remain valid for as long as C may invoke it.

A common pattern passes a user-data pointer:

```c
void register_callback(void (*fn)(void *user, int event), void *user);
```

The Odin side should store callback state in stable memory, convert the raw pointer in one narrow trampoline, and avoid unwinding assumptions across the boundary.

## 22.10 Threading rules

A foreign library may invoke callbacks from worker threads. That affects allocator context, thread-local state, UI rules, and synchronization. Do not assume callbacks run on the registering thread unless documented.

## 22.11 Error translation

C APIs commonly report errors through:

- sentinel return values;
- integer codes;
- `errno`;
- out parameters;
- thread-local library state;
- owned error objects.

Translate these immediately into an Odin-facing result type. Preserve the original code for diagnostics, but do not force every caller to understand raw C conventions.

## 22.12 Variadic functions

C variadic functions provide weak type safety. Prefer typed alternatives or a C shim. Format-string mismatches can corrupt calls even when compilation succeeds.

## 22.13 Macros and inline functions

Macros are not linkable symbols. Translate simple constants and expressions manually, or expose them through a C shim. The same applies to `static inline` functions that do not produce an external symbol.

## 22.14 Calling Odin from C

An Odin procedure exported to C must use a stable symbol name, C-compatible calling convention, and ABI-safe parameters. Keep exported surfaces narrow and versioned. Avoid exposing Odin-specific containers, strings, allocators, or internal layouts directly.

A robust exported API often uses:

- opaque handles;
- fixed-width integers;
- pointer-plus-length buffers;
- explicit result codes;
- separate create/destroy functions.

## 22.15 Wrapper architecture

Use three layers:

1. raw declarations that mirror the C API;
2. a thin safety wrapper that handles ownership and errors;
3. domain code that no longer depends on C conventions.

This preserves access to the original API while preventing ABI details from spreading through the application.

## 22.16 Verification

Verify bindings with:

- size and alignment assertions;
- known constants;
- minimal smoke calls;
- callback tests;
- ownership tests under repeated create/destroy cycles;
- tests on every supported target ABI.

## 22.17 Common mistakes

### Treating `string` as `cstring`

Length-delimited and null-terminated strings have different invariants.

### Guessing struct layout

One incorrect field width shifts every following field.

### Hiding ownership in a convenience wrapper

A wrapper that returns an undocumented borrowed pointer is less safe than the raw API.

### Binding every symbol

Bind the subset the project uses, then expand deliberately.

## 22.18 Chapter checklist

You should now be able to:

- declare foreign libraries and procedures;
- select C-compatible types;
- handle C strings, arrays, structs, and opaque handles;
- reason about callbacks and thread rules;
- translate errors and ownership;
- design a narrow layered wrapper.

## References

- [Odin foreign system](https://odin-lang.org/docs/overview/#foreign-system)
- [Odin `core:c` package](https://pkg.odin-lang.org/core/c/)
- [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI)

---

[Exercises](../exercises/22-c-interoperability.md) · [Solutions](../solutions/22-c-interoperability.md)