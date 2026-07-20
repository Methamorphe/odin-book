# Chapter 15 — Allocators and `context.allocator`

[← Chapter 14: The Odin Memory Model](14-memory-model.md) · [Exercises](../exercises/15-allocators-context.md) · [Chapter 16: Arenas, Pools, and Temporary Memory →](16-arenas-pools-temporary-memory.md)

An allocator is a policy for obtaining and releasing memory. Odin makes allocator choice explicit enough to support systems design while still providing a convenient default through `context.allocator`.

## 15.1 Why allocators are values

Different workloads need different policies:

- a general-purpose heap for unrelated lifetimes;
- an arena for many values released together;
- a pool for fixed-size objects;
- a temporary allocator for scratch work;
- a tracing allocator for diagnostics;
- a foreign allocator required by an API.

Passing allocator values lets the same code operate under different lifetime strategies.

## 15.2 The current context

Odin procedures have access to a `context` value containing services such as the current allocator. Code that calls `make`, `new`, or related facilities can use `context.allocator` when no allocator is specified directly.

This is convenient, but it is still a dependency. Treat allocator context as part of the procedure's execution environment.

## 15.3 Allocate and release symmetrically

```odin
values := make([]int, 256)
defer delete(values)
```

The allocator used to release memory must match the allocator that created it. Do not allocate in one subsystem and destroy through an unrelated allocator.

## 15.4 Explicit allocator parameters

Library code with important ownership behavior should often accept an allocator:

```odin
load_document :: proc(path: string, allocator: mem.Allocator) -> (Document, bool)
```

This makes the contract visible and allows callers to choose a heap, arena, test allocator, or subsystem allocator.

## 15.5 Temporarily replacing context

A scope can use a different allocator by copying and modifying the context before calling code that relies on defaults. This is useful when integrating existing procedures into a bounded lifetime region.

The key rule is that any value escaping that scope must not depend on memory that will be reclaimed too early.

## 15.6 Allocation failure

Systems code should decide whether allocation failure is recoverable, fatal, or impossible under a bounded design. The correct policy depends on the product:

- a command-line tool may report and exit;
- a game may unload optional assets;
- an embedded system may use fixed-capacity storage;
- a server may reject a request but remain alive.

Do not ignore failure policy merely because desktop heaps usually succeed.

## 15.7 Allocator ownership

An allocator may itself own state. A heap wrapper, arena, pool, or tracking allocator must remain alive as long as any allocation made through it remains alive.

```text
Allocator state lifetime >= every allocation produced by it
```

Destroying allocator state before its allocations is invalid even if their raw addresses still appear accessible.

## 15.8 Subsystem allocators

Large applications benefit from allocator boundaries:

```text
Application heap
├── Asset subsystem allocator
├── Editor document allocator
├── Network connection arenas
└── Per-frame temporary allocator
```

This supports bulk cleanup, memory accounting, leak isolation, and predictable shutdown.

## 15.9 Tracking allocations

A diagnostic allocator can record:

- requested size and alignment;
- call site;
- allocation count;
- peak bytes;
- outstanding blocks;
- subsystem tag.

Use tracking in development builds to detect leaks and unexpected allocation hot spots. Keep measurement overhead out of performance conclusions unless accounted for.

## 15.10 Avoid allocator confusion in APIs

A procedure returning allocated memory should state:

- which allocator produced it;
- who owns it;
- how to release it;
- whether nested fields share the same allocator;
- whether the caller may retain it.

Naming can help:

```odin
clone_string :: proc(value: string, allocator: mem.Allocator) -> string
borrow_name  :: proc(record: ^Record) -> string
```

`clone` suggests ownership; `borrow` suggests a view.

## 15.11 Containers and allocators

Dynamic arrays, maps, builders, and many library facilities allocate backing storage. Their descriptor may be copied while the allocation remains owned by one logical component.

Store allocator information with a resource-owning object when destruction cannot reliably recover it from context.

## 15.12 Reallocation

Growing a dynamic container may allocate a new block, copy elements, and release the old block. Consequences include:

- interior pointers become invalid;
- old slices may no longer describe valid storage;
- peak memory temporarily includes old and new blocks;
- allocator behavior affects growth cost.

Reserve expected capacity when estimates are reliable.

## 15.13 Allocator-aware constructors

```odin
Document :: struct {
    allocator: mem.Allocator,
    text: [dynamic]u8,
}

init_document :: proc(allocator: mem.Allocator) -> Document {
    result: Document
    result.allocator = allocator
    make(&result.text, allocator)
    return result
}
```

The matching destroy procedure uses the stored allocator and destroys nested resources before the object itself.

## 15.14 Zero allocations as a design target

Reducing allocations can improve predictability, but "zero allocations" is not inherently superior. One well-scoped allocation may be clearer and faster than complex fixed-capacity machinery.

Optimize allocation count when profiling or product constraints justify it.

## 15.15 Worked design: asset loading

An asset loader might use:

- a temporary arena for parsing scratch memory;
- a persistent asset allocator for decoded runtime data;
- a GPU API allocator for driver-owned objects;
- a staging allocator for upload buffers.

The loader must ensure only persistent data escapes the temporary parse scope.

## 15.16 Common mistakes

- releasing with a different allocator;
- allowing arena-backed values to escape an arena lifetime;
- relying on whatever allocator happens to be in context during destruction;
- copying a container descriptor and accidentally creating two logical owners;
- measuring allocations without separating temporary and persistent categories;
- hiding allocation in frequently called APIs.

## 15.17 Chapter checklist

You should now understand allocator values, `context.allocator`, explicit allocator parameters, allocator lifetime, subsystem boundaries, tracking, reallocation, and allocator-aware ownership contracts.

## References

- [Odin core memory package](https://pkg.odin-lang.org/core/mem/)
- [Odin overview](https://odin-lang.org/docs/overview/)
