# Chapter 14 Solutions — The Odin Memory Model

[← Exercises](../exercises/14-memory-model.md) · [Chapter](../book/14-memory-model.md)

A useful ownership graph is:

```text
Application owns World
World owns dynamic entity backing storage
Systems borrow slices during update
Borrows end before mutation, growth, or destruction
```

Copying a slice duplicates only its descriptor: pointer and length. Both descriptors still refer to the same elements.

A parser returning slices into temporary input is safe only while the original buffer remains alive and unchanged. Copy retained values into longer-lived storage.

Field-order experiments should record size, alignment, and offsets rather than assuming the sum of field sizes. For the lifetime design, keep world data in a persistent allocator, frame scratch in a resettable arena, and submission buffers alive until the GPU synchronization point proves they are reusable.
