# Chapter 4 — Values, Variables and Constants

[← Chapter 3: Your First Odin Program](03-first-program.md) · [Exercises](../exercises/04-values-variables-constants.md) · [Chapter 5: Primitive and Named Types →](05-primitive-and-named-types.md)

Odin's declaration syntax is compact, but the distinction between runtime variables and compile-time constants is fundamental. Misunderstanding `:=` and `::` leads to incorrect assumptions about mutability, storage, addressability, and conversion.

## 4.1 The anatomy of a declaration

A fully explicit variable declaration has this form:

```odin
name: Type = value
```

For example:

```odin
score: int = 100
```

The three parts are:

- `score`: the name introduced in the current scope;
- `int`: the declared type;
- `100`: the initial value.

Odin lets you omit information the compiler can determine:

```odin
score: = 100
score := 100
```

These forms are equivalent in this case. `:=` is not a mysterious single operator; it is declaration syntax formed from `:` and `=`.

## 4.2 Variables are runtime-known values

A variable represents storage whose value exists at runtime:

```odin
lives := 3
lives = 2
```

The first line declares and initializes `lives`. The second assigns a new value to the existing variable.

Declaration and assignment are different operations:

```odin
count := 1 // declaration
count = 2  // assignment
```

Attempting to redeclare the same name in the same scope is an error:

```odin
count := 1
count := 2 // error: redeclaration in the same scope
```

A nested scope may introduce a new declaration with the same name, but shadowing should be deliberate:

```odin
count := 1
{
    count := 99
    fmt.println(count) // 99
}
fmt.println(count)     // 1
```

Excessive shadowing makes state changes harder to follow.

## 4.3 Zero initialization

Variables without an explicit initializer receive the zero value for their type:

```odin
count: int       // 0
enabled: bool    // false
ratio: f32       // 0.0
pointer: ^int    // nil
```

Zero initialization makes local state predictable, but it does not make every zero value semantically valid. A zeroed file handle, entity ID, or network address may still violate your application's invariants.

Represent invalid states explicitly when they matter.

## 4.4 Multiple declarations and assignments

Odin can declare several variables at once:

```odin
x, y := 10, 20
name, active := "Ada", true
```

It can also assign several existing locations simultaneously:

```odin
x, y = y, x
```

This swaps the values without a temporary variable.

Multiple assignment is particularly useful with procedures that return several values, which Chapter 6 will cover.

## 4.5 Constants are compile-time-known entities

A constant declaration uses `::`:

```odin
Max_Players :: 64
Application_Name :: "Orbit Editor"
```

A constant must be evaluable at compile time. It is not simply a runtime variable protected against assignment.

This matters because a compile-time constant may have no addressable storage of its own:

```odin
Buffer_Size :: 4 * 1024
```

The compiler can substitute the value wherever it is used.

Typed constants are also possible:

```odin
Max_Retries: int : 5
```

The more common inferred form remains:

```odin
Max_Retries :: 5
```

## 4.6 `::` also names procedures and types

The right side of `::` is not limited to numeric or string literals:

```odin
add :: proc(a, b: int) -> int {
    return a + b
}

User_ID :: distinct u64
```

Both the procedure value and the type are compile-time-known declarations.

A useful mental model is:

- `:=` introduces runtime storage with an inferred type;
- `::` introduces a compile-time-known declaration with an inferred type.

## 4.7 Untyped constants

Literal constants in Odin begin as untyped values. They can adopt a compatible type when context requires one:

```odin
small: u8 = 12
large: i64 = 12
ratio: f32 = 12
```

The literal `12` is accepted in each context because it can be represented without invalid loss.

This is not unrestricted implicit conversion between arbitrary runtime values. Odin remains strict about distinct runtime types.

A constant that cannot fit is rejected:

```odin
value: u8 = 300 // error
```

Untyped constants make expressions convenient while preserving checks at the point where a concrete type is required.

## 4.8 Numeric constant expressions

The compiler can evaluate arithmetic at compile time:

```odin
Kilobyte :: 1024
Megabyte :: 1024 * Kilobyte
Default_Buffer_Size :: 4 * Megabyte
```

Constants are useful for dimensions, masks, limits, and configuration that truly belongs to the program definition.

Do not turn every value into a global constant. Prefer narrow scope and local declarations when a value is relevant to only one procedure or package.

## 4.9 Mutability is not ownership

A mutable variable does not tell you who owns the resources reachable through it. Consider:

```odin
name: string = "Ada"
```

The variable `name` can be assigned another string value, but that says nothing by itself about where the string data lives or who must free memory. Later chapters separate:

- value mutability;
- pointer mutability;
- resource ownership;
- allocator lifetime.

Keeping these concepts separate prevents C++-style assumptions from leaking into Odin designs.

## 4.10 Scope and lifetime

A declaration is visible from its declaration point to the end of its scope:

```odin
main :: proc() {
    outer := 10

    if outer > 0 {
        inner := 20
        fmt.println(outer, inner)
    }

    // `inner` is no longer in scope here.
}
```

Scope is a language visibility rule. Lifetime describes how long storage or resources remain valid. Local scalar variables usually have straightforward lifetimes, but pointers, dynamic arrays, and allocated memory require more careful reasoning.

## 4.11 Addressability

Runtime variables generally occupy storage and can be addressed:

```odin
value := 42
pointer := &value
```

Compile-time constants are different. You cannot assume a `::` constant has stable runtime storage whose address can be taken.

When you need read-only runtime data with storage, use an appropriate runtime declaration and attributes documented by Odin rather than pretending a compile-time constant is a C-style `static const` object.

The official FAQ discusses `@(rodata)` for values that should reside in read-only data:

```odin
@(rodata)
Lookup_Table := [4]u8{10, 20, 30, 40}
```

This is an advanced distinction, but learning it early avoids a common source of confusion.

## 4.12 Naming conventions

Odin code commonly uses `snake_case` for local variables and procedures. Constants and types often use descriptive capitalized names, but consistency within a codebase matters more than imitating conventions mechanically.

Prefer names that expose units and meaning:

```odin
retry_count := 3
timeout_ms := 2_500
texture_width_px := 1024
```

Avoid vague names such as `data`, `value`, or `tmp` when the scope is large enough for ambiguity.

## 4.13 Grouping related declarations

Keep related configuration close together:

```odin
Window_Width  :: 1280
Window_Height :: 720
Window_Title  :: "Odin Sandbox"
```

Aligning declarations can improve scanning when it does not produce noisy diffs. Use the formatter and project conventions rather than manually forcing presentation everywhere.

## 4.14 Common mistakes

### Treating `::` as immutable runtime storage

A compile-time constant is not equivalent to `const` in every other language. Think in terms of compile-time evaluation and declaration, not merely write protection.

### Using `:=` when an explicit type communicates intent

Inference is useful:

```odin
attempts := 0
```

But an explicit type is clearer at boundaries or when width matters:

```odin
packet_size: u32 = 0
entity_id: u64 = 0
```

### Relying on default integer width in serialized data

`int` is appropriate for many local computations. Use fixed-width integers when binary layout, protocol compatibility, or file formats demand them.

### Confusing assignment with redeclaration

Use `=` to change an existing variable and `:=` to introduce a new one.

## 4.15 Worked example: frame timing configuration

```odin
package main

import "core:fmt"

Target_Frames_Per_Second :: 60
Nanoseconds_Per_Second   :: 1_000_000_000
Target_Frame_Time_NS     :: Nanoseconds_Per_Second / Target_Frames_Per_Second

main :: proc() {
    frame_index: u64 = 0
    running := true

    fmt.println("target FPS:", Target_Frames_Per_Second)
    fmt.println("frame budget (ns):", Target_Frame_Time_NS)
    fmt.println("first frame:", frame_index)
    fmt.println("running:", running)
}
```

The constants describe compile-time configuration. The variables describe runtime state. This separation scales well to larger systems.

## 4.16 What you should retain

Odin declarations become easier when you ask one question: **is this name bound to runtime storage or to a compile-time-known entity?**

```text
name: Type = value   runtime variable, explicit type
name := value        runtime variable, inferred type
name: Type : value   compile-time constant, explicit type
name :: value        compile-time declaration, inferred type
```

Inference should remove redundancy, not erase important design information.

## Further reading

- [Official Odin overview: variable and constant declarations](https://odin-lang.org/docs/overview/)
- [Official FAQ: declaration syntax](https://odin-lang.org/docs/faq/)
- [On the Aesthetics of the Syntax of Declarations](https://www.gingerbill.org/article/2018/03/12/on-the-aesthetics-of-the-syntax-of-declarations/)

---

[← Chapter 3: Your First Odin Program](03-first-program.md) · [Exercises](../exercises/04-values-variables-constants.md) · [Chapter 5: Primitive and Named Types →](05-primitive-and-named-types.md)
