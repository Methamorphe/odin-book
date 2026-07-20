# Chapter 6 — Procedures and Multiple Return Values

[← Chapter 5: Primitive and Named Types](05-primitive-and-named-types.md) · [Exercises](../exercises/06-procedures.md) · [Chapter 7: Control Flow →](07-control-flow.md)

Procedures are Odin's primary unit of behavior. They receive explicitly typed inputs, produce explicitly typed outputs, and can be stored, passed, and composed like other values. Odin does not require classes or methods to organize behavior: procedures and data structures are enough to build both small tools and large systems.

## 6.1 Declaring a procedure

```odin
add :: proc(a, b: int) -> int {
    return a + b
}
```

The declaration has four parts:

- `add` is the name;
- `::` declares a compile-time entity;
- `proc(a, b: int)` describes the parameters;
- `-> int` describes the result.

Call it with ordinary function-call syntax:

```odin
sum := add(20, 22)
```

Parameter names are part of the declaration and should communicate domain meaning. Prefer `width, height` to `a, b` outside tiny mathematical helpers.

## 6.2 No return value

A procedure that performs work without returning a value omits the arrow:

```odin
print_banner :: proc(title: string) {
    fmt.println("===", title, "===")
}
```

This does not mean the procedure has no observable effect. It may print, mutate memory through a pointer, write a file, or update a system. Make effects visible in naming and API boundaries.

## 6.3 Multiple return values

Odin supports multiple results directly:

```odin
divide_with_remainder :: proc(value, divisor: int) -> (quotient, remainder: int) {
    quotient = value / divisor
    remainder = value % divisor
    return
}
```

Use the results through destructuring:

```odin
q, r := divide_with_remainder(17, 5)
```

Named results can improve readability, but they should not become hidden mutable state. Use a direct return when it is clearer:

```odin
min_max :: proc(a, b: int) -> (int, int) {
    if a < b {
        return a, b
    }
    return b, a
}
```

Multiple results are especially useful for operations that produce a value plus status information:

```odin
parse_port :: proc(text: string) -> (port: u16, ok: bool)
```

This keeps error handling explicit without requiring exceptions.

## 6.4 Ignoring a result

Use `_` when one result is intentionally irrelevant:

```odin
quotient, _ := divide_with_remainder(17, 5)
```

The underscore documents intent better than inventing an unused variable.

## 6.5 Named arguments

At call sites, named arguments can clarify meaning:

```odin
resize(width = 1920, height = 1080, preserve_aspect = true)
```

Use them when several adjacent arguments share a type or when booleans would otherwise be cryptic. Do not use named arguments merely to repeat obvious information.

## 6.6 Default parameters

Procedures can provide defaults:

```odin
log_message :: proc(message: string, level := "info") {
    fmt.printf("[%s] %s\n", level, message)
}
```

Calls may omit the defaulted argument:

```odin
log_message("server started")
log_message("disk nearly full", level = "warning")
```

Defaults belong on stable convenience choices. Avoid using them to hide important policy decisions such as ownership, allocation strategy, or security behavior.

## 6.7 Procedure overloading

Odin supports procedure groups with `proc` overload sets:

```odin
length_i32 :: proc(value: [2]i32) -> f32 { /* ... */ }
length_f32 :: proc(value: [2]f32) -> f32 { /* ... */ }

length :: proc{length_i32, length_f32}
```

Overloading is useful when operations share one semantic meaning across a small, controlled set of types. Excessive overloading can make code search and diagnostics harder. Prefer distinct names when operations differ conceptually.

## 6.8 Procedure values

A procedure can be assigned to a variable:

```odin
Operation :: proc(int, int) -> int

apply :: proc(operation: Operation, a, b: int) -> int {
    return operation(a, b)
}
```

```odin
multiply :: proc(a, b: int) -> int {
    return a * b
}

result := apply(multiply, 6, 7)
```

Procedure values are useful for callbacks, dispatch tables, test seams, job systems, and configurable algorithms. They are explicit and generally easier to inspect than deep inheritance hierarchies.

## 6.9 Calling conventions

Foreign interfaces may require a specific calling convention. Odin lets procedure types express that boundary. Keep ABI-specific declarations close to foreign bindings and translate them into ordinary Odin-facing APIs rather than spreading platform details through the program.

## 6.10 Polymorphic procedures

A dollar-prefixed parameter introduces a compile-time polymorphic value or type:

```odin
clamp :: proc(value, minimum, maximum: $T) -> T {
    if value < minimum {
        return minimum
    }
    if value > maximum {
        return maximum
    }
    return value
}
```

The compiler creates concrete versions for compatible call-site types. Polymorphism should preserve one clear operation across types. It is not a goal by itself.

Constraints can narrow acceptable types. When an API only makes sense for numeric values or a known family of structures, encode that limitation rather than waiting for confusing errors inside the body.

## 6.11 Passing large values

Procedure parameters are values. Passing a large structure by value may copy it. Depending on ownership and mutability, choose among:

- a value for small, independent data;
- `^T` when mutation or identity matters;
- `^const T` for read-only access without a large copy;
- a slice for a view over contiguous elements;
- a handle for long-lived resources managed elsewhere.

Do not mechanically pass everything by pointer. Value semantics simplify reasoning when copying is cheap and intended.

## 6.12 Output parameters

Some low-level or foreign APIs write results through pointers. Native Odin APIs usually read more clearly with return values:

```odin
// Prefer for ordinary Odin code
bounds :: proc(points: []Vec2) -> (minimum, maximum: Vec2)
```

Output parameters remain appropriate when matching an ABI, reusing caller-owned storage, or returning very large data under measured constraints.

## 6.13 Purity and effects

Odin does not enforce pure procedures. You establish useful boundaries through design:

```odin
calculate_tax :: proc(subtotal: Money, rate: f32) -> Money
write_invoice :: proc(path: string, invoice: ^const Invoice) -> bool
```

The first name suggests deterministic computation. The second announces I/O. Keeping computation separate from effects improves testing and reuse.

## 6.14 Early returns

Early returns flatten control flow:

```odin
process_order :: proc(order: ^Order) -> bool {
    if order == nil {
        return false
    }
    if len(order.items) == 0 {
        return false
    }

    // Main path remains unindented.
    return true
}
```

Use guard clauses for invalid states and edge cases. Avoid a single giant exit point when it makes the valid path harder to see.

## 6.15 Common mistakes

### Encoding unrelated behavior in one procedure

A procedure that parses input, performs business logic, writes files, and prints diagnostics is difficult to test. Split around meaningful transformations and effects.

### Returning a boolean with no context

`bool` is suitable when there are exactly two meaningful outcomes. When callers need to know why an operation failed, return a richer enum, error value, or structured result.

### Hiding cost behind generic names

A procedure named `get_texture` that performs disk I/O and decoding violates caller expectations. Names should expose expensive or stateful behavior.

### Overusing polymorphism

A generic helper can reduce repetition, but a concrete procedure often provides better diagnostics, clearer domain types, and easier maintenance.

## 6.16 Worked example

```odin
package main

import "core:fmt"

Operation :: proc(int, int) -> int

add :: proc(a, b: int) -> int { return a + b }
multiply :: proc(a, b: int) -> int { return a * b }

apply :: proc(name: string, operation: Operation, a, b: int) -> int {
    result := operation(a, b)
    fmt.printf("%s(%d, %d) = %d\n", name, a, b, result)
    return result
}

safe_divide :: proc(a, b: int) -> (value: int, ok: bool) {
    if b == 0 {
        return 0, false
    }
    return a / b, true
}

main :: proc() {
    apply("add", add, 20, 22)
    apply("multiply", multiply, 6, 7)

    value, ok := safe_divide(84, 2)
    if ok {
        fmt.println("division:", value)
    }
}
```

## Chapter summary

- Procedures are compile-time declarations that describe explicit inputs and outputs.
- Multiple return values model value-plus-status operations naturally.
- Procedure values support callbacks and configurable behavior without classes.
- Polymorphic procedures should express one coherent operation across types.
- Choose value, pointer, slice, or handle parameters according to ownership and cost.
- Keep effects visible and prefer guard clauses for invalid states.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Odin FAQ](https://odin-lang.org/docs/faq/)

[Exercises →](../exercises/06-procedures.md) · [Next chapter →](07-control-flow.md)
