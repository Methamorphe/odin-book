# Appendix A — Odin Syntax Reference

[← Chapter 48: Packaging a Small Game](48-packaging-small-game.md) · [Appendix B: Standard-Library Field Guide →](appendix-b-standard-library-field-guide.md)

This appendix is a compact lookup guide. It complements the chapters rather than replacing them.

## A.1 Packages and imports

Every source file begins with a package declaration:

```odin
package main
```

Imports may be written individually:

```odin
import "core:fmt"
import "core:os"
```

or grouped:

```odin
import (
    "core:fmt"
    "core:strings"
)
```

Aliases make long or conflicting package names explicit:

```odin
import text "core:strings"
```

## A.2 Declarations

```odin
count: int = 10       // explicit type and value
limit := 64           // inferred variable
MAX_USERS :: 1024     // constant
User_ID :: distinct u64
```

Use `:=` for local inference and `::` for constants, procedures, types, and compile-time declarations.

## A.3 Primitive types

Common scalar types include:

- `bool`;
- signed integers: `i8`, `i16`, `i32`, `i64`, `i128`, `int`;
- unsigned integers: `u8`, `u16`, `u32`, `u64`, `u128`, `uint`, `uintptr`;
- floating point: `f16`, `f32`, `f64`;
- `byte`, an alias suitable for byte-oriented data;
- `rune`, a Unicode code point;
- `string`;
- `cstring` for null-terminated C strings;
- `rawptr` for untyped pointer interoperation.

Prefer fixed-width types at file, network, ABI, and GPU boundaries.

## A.4 Conversions

```odin
small := i32(large)
value := f64(integer)
bytes := transmute([4]u8)word
```

A conversion changes value representation according to language rules. `transmute` reinterprets bits and should be reserved for verified low-level layouts.

## A.5 Arrays and slices

```odin
fixed := [4]int{10, 20, 30, 40}
view: []int = fixed[1:3]
readonly: []const int = fixed[:]
```

An array owns inline storage. A slice is a pointer-and-length view and does not own its backing memory.

Useful operations:

```odin
len(fixed)
cap(view)
raw_data(view)
```

## A.6 Dynamic arrays

```odin
values := make([dynamic]int, 0, 16) or_else panic("allocation failed")
defer delete(values)

_ = append(&values, 10) or_else panic("append failed")
_ = append(&values, 20, 30) or_else panic("append failed")
```

Dynamic arrays own allocator-backed storage. Appending may reallocate and invalidate pointers and slices into the old backing store.

## A.7 Maps

```odin
counts := make(map[string]int) or_else panic("allocation failed")
defer delete(counts)

counts["odin"] = 1
value, found := counts["odin"]
delete_key(&counts, "odin")
```

Map iteration order is not a serialization order. Sort keys when deterministic output matters.

## A.8 Structs

```odin
Position :: struct {
    x, y: f32,
}

Player :: struct {
    name: string,
    position: Position,
    health: int,
}

player := Player{
    name = "Ada",
    position = {10, 20},
    health = 100,
}
```

## A.9 Enums and bit sets

```odin
State :: enum u8 {
    Idle,
    Running,
    Stopped,
}

Permission :: enum {
    Read,
    Write,
    Execute,
}

permissions: bit_set[Permission]
permissions += {.Read, .Write}
```

## A.10 Unions

```odin
Value :: union {
    int,
    f64,
    string,
}

print_value :: proc(value: Value) {
    switch v in value {
    case int:    fmt.println(v)
    case f64:    fmt.println(v)
    case string: fmt.println(v)
    }
}
```

A union value carries its active variant. Use `#no_nil` when a nil state is not permitted.

## A.11 Pointers

```odin
value := 42
pointer: ^int = &value
pointer^ += 1
```

Useful pointer categories include:

- `^T`: pointer to one value;
- `[^]T`: multi-pointer suitable for indexed foreign memory;
- `rawptr`: untyped pointer;
- `^const T`: pointer through which mutation is forbidden.

## A.12 Procedures

```odin
add :: proc(a, b: int) -> int {
    return a + b
}

parse :: proc(text: string) -> (value: int, ok: bool) {
    // ...
    return
}
```

Named arguments improve clarity:

```odin
open_window(width = 1280, height = 720, resizable = true)
```

Variadic arguments:

```odin
sum :: proc(values: ..int) -> int {
    total := 0
    for value in values {
        total += value
    }
    return total
}
```

## A.13 Procedure values and calling conventions

```odin
Comparator :: proc(a, b: int) -> bool
C_Callback :: proc "c" (user_data: rawptr)
```

Use explicit calling conventions at foreign boundaries.

## A.14 Control flow

```odin
if value > 0 {
    // ...
} else if value == 0 {
    // ...
} else {
    // ...
}
```

```odin
switch state {
case .Idle:
case .Running:
case:
}
```

```odin
for i in 0..<10 {}
for value, index in values {}
for condition {}
for {}
```

Use `break`, `continue`, and labelled control flow when needed.

## A.15 `defer`

```odin
file, err := os.open(path)
if err != nil {
    return
}
defer os.close(file)
```

Deferred calls execute in reverse order when the current scope exits.

## A.16 Error-oriented expressions

Procedures may return an error value or an allocator failure result. Common handling forms include explicit checks and `or_else`:

```odin
buffer := make([]u8, 4096) or_else panic("out of memory")
```

Use assertions for programmer invariants, not expected runtime failures.

## A.17 `when` and compile-time conditions

```odin
when ODIN_OS == .Windows {
    // Windows-only declaration
} else when ODIN_OS == .Linux {
    // Linux-only declaration
}
```

`when` removes inactive branches at compile time. `if` chooses at runtime.

## A.18 Polymorphic procedures

```odin
max_value :: proc(a, b: $T) -> T {
    return a if a > b else b
}
```

Constrain polymorphism when the accepted family of types should be limited.

## A.19 `using`

```odin
Transform :: struct {
    position: [3]f32,
}

Entity :: struct {
    using transform: Transform,
    enabled: bool,
}
```

`using` promotes names for convenient access. Avoid it when promotion obscures ownership or creates collisions.

## A.20 Attributes and directives

Common forms include:

```odin
@(test)
example_test :: proc(t: ^testing.T) {}

@(private)
internal_value: int

#assert(size_of(Header) == 16)
```

Attributes attach metadata to declarations. Directives affect compilation or enforce compile-time facts.

## A.21 Foreign declarations

```odin
foreign import libc "system:c"

foreign libc {
    puts :: proc "c" (text: cstring) -> c.int ---
}
```

Keep foreign declarations thin and place ergonomic ownership-aware wrappers in a separate package layer.

## A.22 Context

Odin procedures carry an implicit `context` containing allocator, logger, and other ambient services.

```odin
old_allocator := context.allocator
context.allocator = scratch_allocator
```

Override context only within a controlled scope and document procedures that depend on ambient state.

## A.23 Built-in layout operations

```odin
size_of(T)
align_of(T)
offset_of(T, field)
type_of(value)
typeid_of(T)
```

Use compile-time assertions to protect binary and foreign layouts.

## A.24 Style checklist

- use named types for domain identifiers and units;
- keep ownership visible;
- prefer slices for borrowed sequences;
- avoid long-lived pointers into growable containers;
- keep foreign and binary layouts explicit;
- handle allocation results;
- use `defer` beside acquisition;
- make invalid states difficult to represent;
- measure before optimizing.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Odin package documentation](https://pkg.odin-lang.org/)
