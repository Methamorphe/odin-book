# Chapter 15 Solutions — Allocators and Context

[← Exercises](../exercises/15-allocators-context.md) · [Chapter](../book/15-allocators-context.md)

Prefer contracts such as:

```odin
load_document :: proc(path: string, allocator: mem.Allocator) -> (Document, bool)
```

A resource-owning `Document` should retain the allocator used for its dynamic fields when destruction cannot rely on the caller's current context. Using the current context allocator later may mismatch the allocator that originally produced the memory.

Only values copied into longer-lived storage may escape a temporary allocator scope. Borrowed strings, slices, maps, and nested allocations backed by temporary memory must remain inside it.

A practical editor split is: process allocator for global services, project arena for project metadata, one allocator or arena per open document, asset allocator for persistent decoded assets, and a resettable frame allocator for UI scratch.

Tracking should include allocation count, requested bytes, peak live bytes, outstanding blocks, size and alignment, subsystem tags, and useful call-site information.
