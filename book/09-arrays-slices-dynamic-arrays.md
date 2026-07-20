# Chapter 9 — Arrays, Slices and Dynamic Arrays

[← Chapter 8: Packages](08-packages.md) · [Exercises](../exercises/09-arrays-slices-dynamic-arrays.md) · [Chapter 10: Maps, Strings and Runes →](10-maps-strings-runes.md)

Collections are central to systems programming, but not all collections have the same ownership or cost. Odin distinguishes fixed arrays, slices, and dynamic arrays so that code can express storage and lifetime directly.

## 9.1 Fixed arrays

An array stores a fixed number of elements as part of its value:

```odin
values: [4]int = {10, 20, 30, 40}
```

The length is part of the type. `[4]int` and `[8]int` are different types.

```odin
fmt.println(len(values))
fmt.println(values[0])
```

Arrays are useful when size is known at compile time, when inline storage matters, or when a stable binary layout is required.

## 9.2 Arrays have value semantics

Assigning an array copies its elements:

```odin
a := [3]int{1, 2, 3}
b := a
b[0] = 99
```

`a[0]` remains `1`. This independence is useful, but copying large arrays repeatedly may be expensive. Pass large arrays by pointer or expose a slice when copying is not intended.

## 9.3 Array literals and zero values

Unspecified elements are zero-initialized:

```odin
buffer: [1024]byte
```

This creates inline storage containing zero bytes. Zero initialization gives deterministic starting state, though clearing very large memory regions still has a runtime cost.

## 9.4 Indexing and bounds

```odin
first := values[0]
last := values[len(values)-1]
```

Valid indexes range from `0` to `len(values)-1`. Treat indexes from files, networks, or users as untrusted and validate them before access.

## 9.5 Slices are views

A slice describes a contiguous sequence without owning the underlying storage:

```odin
values := [5]int{10, 20, 30, 40, 50}
middle := values[1:4]
```

`middle` views `20, 30, 40`. Modifying the slice modifies the same storage:

```odin
middle[0] = 99
fmt.println(values[1]) // 99
```

A slice conceptually contains a pointer and a length. Its lifetime cannot exceed the storage it references.

## 9.6 Slicing ranges

Odin uses half-open ranges:

```odin
part := values[start:end]
```

`start` is included and `end` is excluded. Therefore:

```odin
len(values[1:4]) == 3
```

Half-open ranges compose naturally and make lengths equal to `end - start`.

## 9.7 Passing slices

Slices are the default input shape for many algorithms:

```odin
sum :: proc(values: []int) -> int {
    total := 0
    for value in values {
        total += value
    }
    return total
}
```

The procedure accepts arrays, dynamic-array contents, or other contiguous storage through a lightweight view.

Use a const-qualified view when the procedure should not mutate elements:

```odin
average :: proc(values: []const f32) -> f32
```

This documents and enforces read-only intent.

## 9.8 Slice lifetime hazards

Never return a slice that points to temporary local storage:

```odin
bad :: proc() -> []int {
    local := [3]int{1, 2, 3}
    return local[:] // invalid lifetime design
}
```

The backing storage disappears when the procedure returns. Return an owning value, allocate in caller-controlled memory, or accept an output buffer.

## 9.9 Dynamic arrays own growable storage

A dynamic array can change length and capacity:

```odin
numbers: [dynamic]int
append(&numbers, 10)
append(&numbers, 20)
delete(numbers)
```

Dynamic arrays allocate memory through an allocator. Their lifetime must be managed explicitly.

A typical scope uses `defer`:

```odin
numbers: [dynamic]int
 defer delete(numbers)
```

In real code, ensure cleanup is registered immediately after successful initialization.

## 9.10 Length and capacity

- length is the number of initialized elements;
- capacity is the amount of storage available before growth requires reallocation.

Appending beyond capacity may move the backing storage. Any pointers or slices into the old storage can become invalid.

```odin
items: [dynamic]int
reserve(&items, 128)
```

Reserve capacity when a reasonable upper bound is known and reallocation would be costly or would invalidate views.

## 9.11 Appending and removing

```odin
append(&items, value)
append(&items, more_values...)
```

Removal policy matters. Stable removal preserves order but may shift later elements. Unordered removal can replace the removed element with the last element and reduce length, which is often faster.

Choose based on domain semantics, not convenience.

## 9.12 Mutating while iterating

Removing elements during forward iteration can skip values. Common strategies include:

- iterate backward;
- use a write cursor to compact kept values;
- collect removals and apply later;
- use unordered removal and re-check the replaced index.

Write-cursor compaction is predictable:

```odin
write := 0
for value in items {
    if should_keep(value) {
        items[write] = value
        write += 1
    }
}
items = items[:write]
```

## 9.13 Array programming and cache locality

Contiguous arrays are efficient because nearby elements occupy nearby memory. Sequential iteration often works well with CPU caches and prefetching.

This is one reason data-oriented systems prefer arrays of homogeneous data over graphs of individually allocated objects.

## 9.14 Array of structs versus struct of arrays

Array of structs:

```odin
Entity :: struct { position: Vec3, velocity: Vec3, health: f32 }
entities: []Entity
```

Struct of arrays:

```odin
Entities :: struct {
    positions: []Vec3,
    velocities: []Vec3,
    health: []f32,
}
```

The first is convenient when all fields are processed together. The second can improve locality when systems touch only selected fields. Measure according to actual access patterns.

## 9.15 Caller-owned buffers

A procedure can accept caller-provided storage:

```odin
collect_visible :: proc(objects: []const Object, output: []Object_ID) -> int
```

The return value can report how many entries were written. This avoids hidden allocation and gives callers control over memory and reuse.

## 9.16 Multidimensional arrays

```odin
grid: [10][20]u8
```

This is an array of arrays. Understand row-major layout and iteration order when cache behavior matters. Flattened storage can simplify dynamic dimensions:

```odin
index := y * width + x
cell := cells[index]
```

## 9.17 Common mistakes

### Confusing a slice with ownership

A slice does not keep its backing storage alive and does not automatically free it.

### Keeping pointers across growth

Appending to a dynamic array may relocate storage. Recompute indexes, pointers, and slices after operations that can grow it.

### Using dynamic arrays for fixed-size data

If the size is known and small, a fixed array avoids allocation and communicates the invariant.

### Copying large arrays accidentally

Remember that arrays are values. Use slices or pointers when copying is not intended.

## 9.18 Worked example

```odin
package main

import "core:fmt"

sum :: proc(values: []const int) -> int {
    total := 0
    for value in values {
        total += value
    }
    return total
}

main :: proc() {
    fixed := [5]int{1, 2, 3, 4, 5}
    window := fixed[1:4]
    fmt.println("window sum:", sum(window))

    numbers: [dynamic]int
    defer delete(numbers)

    reserve(&numbers, 8)
    for value in fixed {
        append(&numbers, value * 10)
    }

    fmt.println("dynamic sum:", sum(numbers[:]))
}
```

## Chapter summary

- Fixed arrays own inline storage and have value semantics.
- A slice is a non-owning pointer-and-length view.
- Dynamic arrays own growable allocator-backed storage.
- Growth can invalidate pointers and slices into dynamic-array storage.
- Use caller-owned buffers and reserved capacity when allocation control matters.
- Choose data layouts according to access patterns and measured performance.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)

[Exercises →](../exercises/09-arrays-slices-dynamic-arrays.md) · [Next chapter →](10-maps-strings-runes.md)
