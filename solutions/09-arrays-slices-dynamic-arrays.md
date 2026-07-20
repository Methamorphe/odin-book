# Chapter 9 Solutions — Arrays, Slices and Dynamic Arrays

[← Exercises](../exercises/09-arrays-slices-dynamic-arrays.md) · [Chapter →](../book/09-arrays-slices-dynamic-arrays.md)

## 1. Fixed array sum

```odin
values := [8]u8{1, 2, 3, 4, 5, 6, 7, 8}
total: int
for value in values { total += int(value) }
```

## 2. Array copy

Assign `b := a`, mutate `b[0]`, and print both first elements. Arrays have value semantics, so `a` is unchanged.

## 3. Slice mutation

```odin
values := [5]int{1, 2, 3, 4, 5}
middle := values[1:4]
middle[0] = 99
```

`values[1]` becomes `99` because the slice borrows the same storage.

## 4. Average

```odin
average :: proc(values: []const f32) -> f32 {
    if len(values) == 0 { return 0 }
    total: f32
    for value in values { total += value }
    return total / f32(len(values))
}
```

## 5. Local slice lifetime

A local array's storage ends with the procedure scope. A returned slice would point to storage that is no longer valid.

## 6. Dynamic array

```odin
items: [dynamic]int
defer delete(items)
reserve(&items, 100)
for i := 0; i < 100; i += 1 { append(&items, i) }
```

## 7. Invalidation

A slice points into the current backing allocation. An append beyond capacity may move the array, leaving the old slice pointing at obsolete storage.

## 8. Write-cursor compaction

```odin
write := 0
for value in items {
    if value % 2 == 0 {
        items[write] = value
        write += 1
    }
}
items = items[:write]
```

## 9. Data layout

A struct-of-arrays layout keeps positions contiguous without interleaving unrelated fields. This can improve cache behavior when the update touches only positions.

## 10. Caller-owned output

```odin
collect_positive :: proc(input: []const int, output: []int) -> int {
    written := 0
    for value in input {
        if value <= 0 || written == len(output) { continue }
        output[written] = value
        written += 1
    }
    return written
}
```
