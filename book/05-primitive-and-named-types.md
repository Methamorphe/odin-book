# Chapter 5 — Primitive and Named Types

[← Chapter 4: Values, Variables and Constants](04-values-variables-constants.md) · [Exercises](../exercises/05-primitive-and-named-types.md) · [Chapter 6: Procedures and Multiple Return Values →](06-procedures.md)

Types define which values a program can represent and which operations are valid. Odin's type system is deliberately strict: values do not silently drift between unrelated runtime types, and a `distinct` type can turn domain meaning into a compile-time constraint.

This chapter covers scalar built-in types, literals, conversions, aliases, and distinct named types. Compound types such as arrays, slices, structs, enums, unions, and pointers receive dedicated chapters later.

## 5.1 Booleans

The `bool` type has two values:

```odin
enabled: bool = true
finished := false
```

Boolean conditions are explicit. Odin does not treat arbitrary integers or pointers as truth values:

```odin
count := 3

if count { // error: count is not bool
}
```

Write the actual condition:

```odin
if count > 0 {
}
```

This removes a large class of accidental truthiness bugs.

## 5.2 Integers

Odin provides signed and unsigned integer types with explicit widths:

```text
i8   i16   i32   i64   i128
u8   u16   u32   u64   u128
```

It also provides general-purpose integer types such as `int` and `uint`, whose sizes are appropriate to the target architecture, plus pointer-sized forms used in low-level work.

Examples:

```odin
health: int = 100
packet_length: u32 = 1_024
world_seed: u64 = 0xCAFE_BABE
signed_delta: i16 = -12
```

Use `int` for ordinary indexes, counts, and arithmetic when no external representation requires a fixed width. Use fixed-width types when communicating with:

- binary files;
- network protocols;
- GPU APIs;
- foreign functions;
- hardware registers;
- stable serialized layouts.

Choosing `u8` merely because a current value is small can create unnecessary conversions. Width is a representation decision, not a compression wish.

## 5.3 Integer literals

Integer literals support decimal, binary, octal, and hexadecimal notation:

```odin
decimal := 255
binary  := 0b1111_1111
octal   := 0o377
hex     := 0xff
```

Underscores improve readability and do not affect the value:

```odin
population := 1_000_000
mask := 0b1111_0000_1010_0101
```

Untyped integer constants adopt a concrete type from context when representable:

```odin
small: u8 = 255
large: i64 = 255
```

A value outside the target range is rejected.

## 5.4 Floating-point numbers

The common floating-point types are:

```text
f16   f32   f64
```

Use `f32` frequently in graphics, simulation data, and memory-sensitive numerical arrays. Use `f64` when additional precision is required or when integrating with APIs that define double-precision values.

```odin
opacity: f32 = 0.75
world_time: f64 = 12_345.6789
```

Floating-point values are approximations. Do not compare computed values for exact equality unless the representation and operation make equality intentional:

```odin
epsilon: f32 = 0.0001
if abs(a - b) < epsilon {
    // close enough for this domain
}
```

The correct tolerance depends on the magnitude and problem domain; a single global epsilon is rarely universally correct.

## 5.5 Complex and quaternion values

Odin includes complex-number and quaternion types useful in mathematical and graphics code. Their presence reflects the language's focus on numerical and data-oriented workloads.

Do not use them only because they exist. Choose mathematical representations based on the operations and numerical behavior your system requires. Later graphics chapters will revisit vectors, matrices, and rotations in context.

## 5.6 Bytes, runes, and strings

A byte is represented by `byte`, an alias suited to raw 8-bit data. A Unicode code point is represented by `rune`.

```odin
raw: byte = 0xff
letter: rune = 'λ'
```

A `string` is a view of immutable byte data with a length. It is not an owning, growable string object:

```odin
message: string = "Hello, Odin"
fmt.println(len(message))
```

Important consequences follow:

- `len(string)` reports bytes, not necessarily user-perceived characters;
- indexing a string addresses bytes;
- Unicode text may require rune-aware iteration or text-processing packages;
- string storage and ownership depend on how the string was produced.

Chapter 10 covers strings and Unicode in depth.

## 5.7 `uintptr`, pointers, and `rawptr`

Low-level programs sometimes need integer representations of addresses or untyped pointers. Odin exposes facilities for this work, but conversions around addresses should remain rare and isolated.

Prefer typed pointers such as `^Texture` over `rawptr` because typed pointers preserve more compiler information. Use address-sized integer types only when an ABI, operating-system API, allocator, or data structure genuinely requires them.

Pointers are covered fully in Chapter 12.

## 5.8 The `typeid` type

Odin can represent type information at runtime through `typeid`. This supports reflection and type-driven systems:

```odin
id: typeid = typeid_of(int)
```

Reflection is useful for serialization, editor tooling, debugging, and generic infrastructure. It is not a substitute for a clear static design. Chapter 26 examines reflection and compile-time facilities in detail.

## 5.9 Explicit conversions

Odin avoids broad implicit conversions between runtime values. Convert deliberately:

```odin
count_u32: u32 = 42
count_i64 := i64(count_u32)
ratio := f32(count_u32) / 100.0
```

The cast-style syntax is also available:

```odin
count_i64 := cast(i64)count_u32
```

Both forms express an explicit conversion. Choose the form that keeps the expression readable.

An explicit conversion tells the compiler that the programmer intends a representation change; it does not guarantee that the result is semantically safe. Narrowing conversions can lose data:

```odin
large: u32 = 1_000
small := u8(large) // explicit, but the value cannot be represented faithfully
```

Validate ranges before narrowing external or runtime data.

## 5.10 Transmutation is not conversion

A conversion produces a value of another type according to language conversion rules. A transmutation reinterprets the same bits as another type.

These operations solve different problems. Bit reinterpretation is advanced, layout-sensitive, and often tied to foreign interfaces or serialization. Isolate it, assert assumptions, and prefer library helpers when available.

Never use bit reinterpretation merely to silence the type checker.

## 5.11 Type aliases

A type alias gives another name to an existing type without creating a new incompatible type:

```odin
User_Index :: int
```

`User_Index` and `int` remain the same type for assignment and procedure calls. Aliases can improve vocabulary or ease platform abstraction, but they do not enforce domain separation.

Use an alias when two names should remain interchangeable.

## 5.12 Distinct types

A distinct type creates a new type with an underlying representation:

```odin
User_ID :: distinct u64
Order_ID :: distinct u64
```

Although both use `u64` underneath, they are not freely interchangeable:

```odin
user_id := User_ID(42)
order_id := Order_ID(42)

// user_id = order_id // type error
```

This turns domain meaning into compiler-checked structure.

Distinct types are valuable for:

- identifiers from different domains;
- units such as meters and seconds;
- handles and generation IDs;
- resource indexes;
- coordinate spaces;
- validated or normalized values.

## 5.13 Distinct types and explicit boundaries

Consider an API without distinct types:

```odin
load_profile :: proc(user_id: u64) {}
cancel_order :: proc(order_id: u64) {}
```

This compiles even when arguments are accidentally swapped:

```odin
load_profile(order_id)
```

Distinct types reject the mistake:

```odin
User_ID :: distinct u64
Order_ID :: distinct u64

load_profile :: proc(user_id: User_ID) {}
cancel_order :: proc(order_id: Order_ID) {}
```

The runtime representation can remain compact while the source model becomes safer.

## 5.14 Units as types

Distinct types can model units:

```odin
Meters  :: distinct f32
Seconds :: distinct f32
```

Then procedures can document and enforce their inputs:

```odin
speed :: proc(distance: Meters, duration: Seconds) -> f32 {
    return f32(distance) / f32(duration)
}
```

This still requires thoughtful API design. Returning a plain `f32` loses the meaning of meters per second. A richer system might define:

```odin
Meters_Per_Second :: distinct f32
```

Do not build a huge unit framework before the domain requires it, but use types where confusion would be expensive.

## 5.15 Type inference

Inference removes repeated type information:

```odin
name := "Ada"
count := 12
active := true
```

It works best when the initializer makes the type obvious and the exact representation is unimportant.

Prefer an explicit type when:

- an API boundary depends on a width;
- a unit or domain type matters;
- the zero value does not reveal intent;
- a conversion should be visible;
- serialized or foreign data is involved.

Compare:

```odin
id := 0
id: User_ID = 0
```

The second declaration communicates substantially more.

## 5.16 Arithmetic and mixed types

Odin generally requires operands to have compatible types. This prevents accidental promotion chains common in C and C++.

```odin
count: u32 = 10
scale: f32 = 1.5
result := f32(count) * scale
```

The explicit conversion documents the numeric model. In performance-sensitive loops, choose the representation before entering the loop rather than repeatedly converting values.

## 5.17 Overflow and range reasoning

Integer overflow behavior matters in systems code. Do not assume that choosing a larger unsigned type automatically makes arithmetic safe. Check:

- maximum input values;
- intermediate expression widths;
- multiplication before division;
- signed/unsigned boundaries;
- values read from untrusted input.

For example, image buffer size calculation should validate dimensions before allocation:

```odin
pixel_count := u64(width) * u64(height)
byte_count := pixel_count * bytes_per_pixel
```

The wider intermediate reduces one risk but does not remove the need for upper bounds and allocation checks.

## 5.18 Choosing types by domain

A practical hierarchy is:

1. choose a type that represents the domain correctly;
2. make binary width explicit where external layout requires it;
3. use distinct types where values with identical storage must not mix;
4. optimize storage only after measuring real constraints.

Examples:

```odin
entity_count: int
network_sequence: u32
texture_handle: Texture_Handle
elapsed_seconds: f64
vertex_position: [3]f32
```

Each choice communicates a different constraint.

## 5.19 Worked example: strongly typed resource handles

```odin
package main

import "core:fmt"

Texture_Handle :: distinct u32
Mesh_Handle    :: distinct u32

invalid_texture :: Texture_Handle(0)
invalid_mesh    :: Mesh_Handle(0)

print_texture :: proc(handle: Texture_Handle) {
    fmt.println("texture handle:", u32(handle))
}

main :: proc() {
    texture := Texture_Handle(17)
    mesh := Mesh_Handle(17)

    print_texture(texture)
    // print_texture(mesh) // rejected: Mesh_Handle is a different type

    fmt.println("invalid texture:", u32(invalid_texture))
    fmt.println("invalid mesh:", u32(invalid_mesh))
}
```

The explicit conversions at display boundaries are a small cost for preventing whole classes of handle mix-ups.

## 5.20 Common mistakes

### Using `int` in a stable file format

The architecture-dependent convenience of `int` is inappropriate for a format that must have a fixed binary layout.

### Using unsigned types for every non-negative concept

Unsigned arithmetic has its own edge cases, especially around subtraction. Choose it when the representation or domain benefits, not merely because a value is usually positive.

### Replacing domain types with comments

```odin
id: u64 // user id
```

is weaker than:

```odin
id: User_ID
```

### Assuming explicit means safe

A cast can be syntactically valid while truncating, wrapping, or violating a domain invariant. Validate before converting.

### Counting Unicode characters with byte length

`len(text)` measures bytes for a string. Text processing must account for UTF-8 and the distinction between bytes, code points, and grapheme clusters.

## 5.21 What you should retain

Odin's type system rewards precise modeling:

- use `int` for ordinary local integer work;
- use fixed-width integers for stable representations;
- use explicit conversions between runtime types;
- distinguish aliases from `distinct` types;
- use distinct types to prevent accidental domain mixing;
- remember that strings are byte views, not magical text containers.

The best type is not always the smallest type. It is the type that makes invalid operations difficult and valid operations clear.

## Further reading

- [Official Odin overview](https://odin-lang.org/docs/overview/)
- [Official Odin FAQ](https://odin-lang.org/docs/faq/)
- [Built-in package documentation](https://pkg.odin-lang.org/base/builtin/)
- [Odin demo file](https://odin-lang.org/docs/demo/)

---

[← Chapter 4: Values, Variables and Constants](04-values-variables-constants.md) · [Exercises](../exercises/05-primitive-and-named-types.md) · [Chapter 6: Procedures and Multiple Return Values →](06-procedures.md)
