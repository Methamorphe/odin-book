# Chapter 12 Solutions — Pointers and Addressability

[← Exercises](../exercises/12-pointers-addressability.md) · [Chapter](../book/12-pointers-addressability.md)

```odin
swap :: proc(a, b: ^int) {
    temporary := a^
    a^ = b^
    b^ = temporary
}
```

```odin
Transform :: struct { x, y: f32 }
translate :: proc(value: ^Transform, dx, dy: f32) {
    value.x += dx
    value.y += dy
}
```

A local variable's storage ends when its procedure returns, so a pointer to it would dangle. Return the value, allocate through a longer-lived allocator, or let the caller provide storage.

Dynamic-array growth, reserve operations, deletion strategies that move elements, and destruction can invalidate interior pointers. Reacquire them after mutations.

Prefer:

```odin
sum :: proc(values: []int) -> int
```

over an Odin-facing `^int` plus count API.

A generation handle stores an index and generation. Validation checks the index is in range, the slot is occupied, and both generations match.
