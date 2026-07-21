# Chapter 26 — Reflection and Compile-Time Features

[← Chapter 25: SIMD and Numerical Code](25-simd-numerical-code.md) · [Exercises](../exercises/26-reflection-compile-time.md) · [Chapter 27: API Design in Odin →](27-api-design.md)

Odin provides compile-time constants, polymorphic procedures, type information, and reflection facilities without making metaprogramming the center of everyday code. Use them to remove repetition while preserving explicit runtime behavior.

## 26.1 Compile-time versus runtime

A compile-time value is known while the program is built:

```odin
MAX_PLAYERS :: 64
Buffer :: [MAX_PLAYERS]Player
```

Compile-time computation can select types, array lengths, procedure specializations, and platform branches. It cannot depend on runtime files, user input, or network state.

## 26.2 `when`

`when` selects code at compile time:

```odin
when ODIN_OS == .Windows {
    path_separator :: '\\'
} else {
    path_separator :: '/'
}
```

Unlike a runtime `if`, the inactive branch is not part of the compiled program. Use this for target selection and feature composition, not for ordinary business logic.

## 26.3 Polymorphic procedures

A `$` parameter introduces a compile-time type or value parameter:

```odin
clamp :: proc(value, minimum, maximum: $T) -> T {
    if value < minimum do return minimum
    if value > maximum do return maximum
    return value
}
```

The compiler creates suitable specializations. Keep constraints understandable. A polymorphic procedure should still express one coherent algorithm.

## 26.4 Type specialization

Sometimes behavior differs by type. Use compile-time type inspection narrowly and fail clearly for unsupported types. Prefer overloads when a small fixed set of types has genuinely different domain behavior.

Avoid building a hidden template language inside one procedure.

## 26.5 `typeid` and runtime reflection

`typeid_of(T)` identifies a type at runtime. Reflection can inspect type metadata for systems such as:

- serializers;
- editor property panels;
- debug inspectors;
- generic logging;
- asset metadata;
- test-data generation.

Reflection is powerful because it sees structure the compiler knows. It is dangerous when it silently turns every field into a public persistence or editor contract.

## 26.6 Reflection data

A reflected type may expose kind, size, alignment, names, fields, tags, and element information. Exact APIs evolve with Odin, so consult the compiler version’s `core:reflect` package.

Conceptually:

```odin
id := typeid_of(My_Struct)
info := reflect.type_info_of(id)
```

Treat metadata as read-only compiler-owned state.

## 26.7 Struct tags

Field tags attach declarative metadata:

```odin
Player :: struct {
    name: string `json:"name" editor:"readonly"`,
    health: int  `json:"health" min:"0" max:"100"`,
}
```

A tag is just text until a subsystem defines and validates its meaning. Centralize tag parsing and report malformed tags early.

## 26.8 Reflection-based serialization

A generic serializer can walk fields, but production formats need policy:

- field naming;
- omitted fields;
- versioning;
- unsupported pointers and unions;
- ownership of decoded strings and slices;
- stable ordering;
- numeric range validation.

Reflection removes manual traversal, not format design.

## 26.9 Editor inspection

An editor can reflect a struct and render controls by field type. Add explicit metadata for ranges, units, read-only state, and custom widgets. Keep editor-only reflection out of hot runtime paths when possible.

## 26.10 Compile-time assertions

Assert assumptions as early as possible:

```odin
#assert(size_of(Header) == 16)
#assert(align_of(Header) == 4)
```

Compile-time assertions are valuable for ABI declarations, binary layouts, generated tables, and target requirements.

## 26.11 Generated tables without external codegen

Compile-time constants can build lookup tables, masks, or configuration arrays directly in Odin. This keeps generation visible to the compiler and avoids a separate tool when the computation is simple and deterministic.

For large assets or protocol schemas, external generation may still be clearer and faster.

## 26.12 Procedure values and dispatch tables

Compile-time composition can build tables of procedures:

```odin
Handler :: proc(payload: []u8) -> Error
handlers := [Message_Kind]Handler{
    .Ping = handle_ping,
    .Data = handle_data,
}
```

This is often simpler than reflection for closed sets of behavior.

## 26.13 Compile-time cost

Metaprogramming can increase compile time, binary size, and diagnostic complexity. Watch for:

- excessive specializations;
- giant reflected registries;
- repeated compile-time parsing;
- deeply nested type-level conditions;
- generic helpers instantiated across many packages.

Measure build performance as the project grows.

## 26.14 Reflection boundaries

A useful architecture separates:

1. reflected discovery;
2. validated metadata model;
3. runtime execution.

For example, scan fields once during tool initialization, convert them into compact descriptors, then use those descriptors during rendering. Do not repeatedly walk full reflection metadata in every frame.

## 26.15 Alternatives to reflection

Prefer explicit code when:

- the type set is small;
- behavior is domain-specific;
- persistence compatibility matters strongly;
- errors should be caught through direct procedure signatures;
- runtime cost is sensitive.

Reflection is best for structural repetition, not for hiding meaningful decisions.

## 26.16 Common mistakes

### Treating every field as serializable

Pointers, handles, caches, and temporary state often must not cross persistence boundaries.

### Using `when` for runtime configuration

Compile-time branches require a new build to change behavior.

### Over-generalizing a helper

A short duplicated procedure may be clearer than a polymorphic abstraction with obscure constraints.

### Parsing tags repeatedly

Validate and cache metadata once.

## 26.17 Chapter checklist

You should now be able to:

- distinguish compile-time and runtime decisions;
- use `when`, constants, and polymorphic procedures;
- inspect types through reflection;
- define and validate struct-tag conventions;
- use compile-time assertions;
- choose reflection only where structural automation helps.

## References

- [Odin overview: compile-time features](https://odin-lang.org/docs/overview/)
- [Odin `core:reflect`](https://pkg.odin-lang.org/core/reflect/)
- [Odin compiler repository](https://github.com/odin-lang/Odin)

---

[Exercises](../exercises/26-reflection-compile-time.md) · [Solutions](../solutions/26-reflection-compile-time.md)