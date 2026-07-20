# Chapter 6 Solutions — Procedures

[← Exercises](../exercises/06-procedures.md) · [Chapter →](../book/06-procedures.md)

## 1. Subtraction

```odin
subtract :: proc(a, b: int) -> int { return a - b }
```

## 2. Minimum and maximum

```odin
min_max :: proc(a, b: int) -> (int, int) {
    if a < b { return a, b }
    return b, a
}
```

## 3. Safe division

```odin
safe_divide :: proc(a, b: f64) -> (value: f64, ok: bool) {
    if b == 0 { return 0, false }
    return a / b, true
}
```

## 4. Procedure values

```odin
Transform :: proc(f32) -> f32

apply_all :: proc(values: []f32, transform: Transform) {
    for _, i in values {
        values[i] = transform(values[i])
    }
}
```

## 5. Default parameters

```odin
print_value :: proc(value: f64, precision := 2) {
    // Build the desired format according to the formatting API in use.
}
```

Defaults should represent convenience, not hidden policy.

## 6. Guard clauses

Validate invalid states first and return immediately. This leaves the successful path at the lowest indentation level.

## 7. Distinct identifiers

```odin
User_ID :: distinct u64
Order_ID :: distinct u64

load_user :: proc(id: User_ID) {}
cancel_order :: proc(id: Order_ID) {}
```

## 8. `^const T`

Use it when `T` is expensive to copy, the caller retains ownership, and the procedure must not mutate the value.

## 9. Overload set

```odin
add_i32 :: proc(a, b: i32) -> i32 { return a + b }
add_f32 :: proc(a, b: f32) -> f32 { return a + b }
add :: proc{add_i32, add_f32}
```

## 10. Dispatcher

Use `Handler :: proc()` and store handlers in `map[string]Handler`. Look up with the presence result before calling. A production dispatcher should define handler context, error reporting, and command lifetime explicitly.
