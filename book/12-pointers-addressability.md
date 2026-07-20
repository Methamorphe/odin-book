# Chapter 12 — Pointers and Addressability

[← Chapter 11: Structs, Enums, and Unions](11-structs-enums-unions.md) · [Exercises](../exercises/12-pointers-addressability.md) · [Chapter 13: Cleanup and Explicit Errors →](13-defer-explicit-errors.md)

Pointers let a program refer to existing storage instead of copying a value. They are central to mutation, data structures, allocators, foreign interfaces, and high-performance systems code.

## 12.1 Typed pointers

A pointer to a value of type `T` is written `^T`:

```odin
value := 42
pointer: ^int = &value
fmt.println(pointer^)
```

`&value` takes the address. `pointer^` dereferences it.

## 12.2 Mutation through pointers

```odin
increment :: proc(value: ^int) {
    value^ += 1
}

count := 10
increment(&count)
```

The caller can see from `&count` that the procedure receives access to existing storage.

## 12.3 Addressability

Not every expression denotes stable storage. Variables are addressable; temporary expressions generally should not be treated as durable locations. Ask two questions before taking an address:

1. where is this value stored?
2. how long does that storage remain valid?

Pointer correctness is primarily lifetime reasoning.

## 12.4 Nil pointers

Pointers may be `nil`:

```odin
node: ^Node = nil
if node == nil {
    return
}
```

Check optional pointers before dereferencing. Prefer APIs that avoid nullable pointers when absence can be expressed more clearly with a boolean result, union, or handle.

## 12.5 Pointer parameters

Use a value parameter when copying is intended and inexpensive. Use a pointer when:

- the procedure mutates the caller's value;
- copying is undesirable;
- identity matters;
- a foreign API requires an address;
- the value is part of a linked data structure.

Do not pass everything by pointer by habit.

## 12.6 Read-only access

When a procedure needs an address but must not mutate the value, use a pointer-to-const form appropriate to the API. This communicates intent and lets the compiler reject accidental writes.

## 12.7 Pointers to struct fields

```odin
Player :: struct { health: int }

player := Player{health = 100}
health_ptr := &player.health
health_ptr^ -= 25
```

The field pointer is valid only while the containing `player` storage remains valid and unmoved.

## 12.8 Dynamic arrays and invalidation

A pointer into a dynamic array can become invalid when the array grows and reallocates:

```odin
values: [dynamic]int
append(&values, 10)
p := &values[0]
append(&values, 20) // may move the backing storage
```

After a potential reallocation, reacquire pointers and slices. This rule also applies to other containers whose storage may move.

## 12.9 Slices versus pointers

A pointer refers to one typed location. A slice refers to a contiguous sequence and carries a length. Prefer slices for ranges of elements because they preserve bounds information:

```odin
sum :: proc(values: []int) -> int
```

Use a pointer plus count only when required by a low-level or foreign interface.

## 12.10 `rawptr`

`rawptr` erases the pointed-to type. It is useful at allocator, operating-system, and C ABI boundaries, but it removes compiler guarantees.

Keep raw pointers at narrow boundaries. Convert to typed pointers as soon as the representation is known.

## 12.11 Pointer arithmetic

Ordinary application code should prefer arrays, slices, and indexed access. Pointer arithmetic belongs in carefully isolated code dealing with packed buffers, allocators, SIMD blocks, foreign memory, or parsers.

Every arithmetic operation must preserve:

- alignment;
- bounds;
- element representation;
- lifetime;
- provenance of the underlying allocation.

## 12.12 Linked structures

```odin
Node :: struct {
    value: int,
    next: ^Node,
}
```

A linked list is easy to describe but not automatically efficient. Pointer-heavy structures can have poor cache locality. Choose them for stable nodes and insertion properties, not because they are traditional.

## 12.13 Stable handles

Long-lived systems often expose handles instead of pointers:

```odin
Entity_Handle :: distinct u64
```

A handle can remain stable while storage moves, and a generation counter can detect stale references. This is usually safer for game worlds, resource managers, and editor selections.

## 12.14 Escaping local addresses

Never return or store a pointer to data whose lifetime ends first. The conceptual bug is:

```odin
bad :: proc() -> ^int {
    local := 42
    return &local
}
```

The returned address would outlive its storage. Allocate in a longer-lived region or return the value instead.

## 12.15 Foreign interfaces

C APIs often expose output parameters and pointer-count pairs. Wrap them in an Odin-facing API that converts those forms into values, slices, enums, and explicit results. Keep unsafe representation details close to the foreign boundary.

## 12.16 Worked example

```odin
Transform :: struct {
    x, y: f32,
}

translate :: proc(transform: ^Transform, dx, dy: f32) {
    transform.x += dx
    transform.y += dy
}

main :: proc() {
    player := Transform{x = 2, y = 3}
    translate(&player, 5, -1)
}
```

The pointer is borrowed for the duration of the call; ownership remains with `main`.

## 12.17 Common mistakes

- dereferencing `nil`;
- returning an address to expired local storage;
- holding pointers across container reallocation;
- using `rawptr` where `^T` or `[]T` suffices;
- confusing identity with ownership;
- building pointer-heavy data structures without measuring locality.

## 12.18 Chapter checklist

You should now understand typed pointers, addressability, dereferencing, mutation, nil checks, storage lifetime, invalidation, and when handles or slices are better abstractions.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Odin package documentation](https://pkg.odin-lang.org/)
