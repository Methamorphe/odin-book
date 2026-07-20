# Chapter 14 — The Odin Memory Model

[← Chapter 13: Cleanup and Explicit Errors](13-defer-explicit-errors.md) · [Exercises](../exercises/14-memory-model.md) · [Chapter 15: Allocators and `context.allocator` →](15-allocators-context.md)

Memory management in Odin is explicit, but explicit does not mean chaotic. The central task is to understand where data lives, who owns it, how long it remains valid, and which allocator is responsible for releasing it.

## 14.1 Storage duration

Values commonly live in one of several regions:

- registers or compiler-managed temporaries;
- procedure stack frames;
- static program storage;
- allocator-managed memory;
- foreign or operating-system memory.

The syntax of a value does not tell the whole ownership story. A string or slice may be a small descriptor pointing into another region.

## 14.2 Stack storage

Local values usually live for the duration of their procedure call:

```odin
update :: proc() {
    position := Vec2{10, 20}
    // position is valid inside this call
}
```

Stack allocation is fast and naturally reclaimed. Prefer it for bounded temporary values whose size and lifetime are known.

## 14.3 Allocator-managed storage

Data that must outlive a stack frame, grow dynamically, or have a runtime-determined size often uses an allocator:

```odin
values := make([]int, 1024)
defer delete(values)
```

The allocator determines where storage comes from; the owner determines when it is released.

## 14.4 Descriptors versus backing storage

Slices, strings, dynamic arrays, and maps contain metadata that refers to backing storage.

Copying a slice copies its pointer and length, not its elements:

```odin
a := []int{1, 2, 3}
b := a
b[0] = 99 // observes the same backing storage
```

This is one of the most important distinctions in systems programming: value semantics of the descriptor do not imply ownership of the referenced bytes.

## 14.5 Ownership

Ownership is a design rule, not a magic runtime flag. For every allocation, identify:

1. who creates it;
2. who may mutate it;
3. who may borrow it;
4. who destroys it;
5. whether ownership can transfer.

Ambiguous ownership causes leaks, double frees, and dangling references.

## 14.6 Borrowing

A borrowed slice, string, or pointer is valid only while its owner remains alive and its storage remains stable.

```odin
view := buffer[10:20]
```

`view` does not own those elements. Releasing or reallocating `buffer` invalidates the view.

## 14.7 Lifetime diagrams

A useful notation is:

```text
World owns Entity_Array
Entity_Array owns backing storage
System borrows []Entity during update
borrow ends before Entity_Array may grow or be destroyed
```

Write these relationships down for complex subsystems. Memory bugs often become obvious when ownership is expressed in plain language.

## 14.8 Static storage

Package-level constants and some globals live for the program's duration. Global mutable state is easy to access but difficult to reason about, test, and initialize safely. Prefer explicit subsystem state passed through procedures.

## 14.9 Temporary memory

Many operations need memory only until the end of a frame, request, parse, or job. General-purpose allocate/free pairs work, but they can obscure the fact that all values share one lifetime.

Part II will use arenas and temporary allocators to reclaim such groups together.

## 14.10 Alignment

Processors and APIs impose alignment requirements. An address suitable for bytes may not be suitable for a matrix or SIMD vector. Allocators must return storage aligned for the requested type.

Layout-sensitive code should verify:

- size;
- alignment;
- field offsets;
- array stride;
- foreign ABI expectations.

## 14.11 Padding

Struct fields may contain padding:

```odin
Example :: struct {
    flag: bool,
    count: u64,
}
```

The total size may exceed the sum of field sizes because `count` requires alignment. Reordering fields can reduce padding, but clarity and ABI stability may matter more than a few bytes.

## 14.12 Fragmentation

Repeated allocations of varied sizes can fragment memory. Fragmentation matters in long-running processes, games, editors, servers, and tools that repeatedly load and unload resources.

Common responses include:

- arenas for shared lifetimes;
- pools for fixed-size objects;
- size-class allocators;
- compact handles and movable storage;
- batching allocations.

## 14.13 Locality

Correct memory can still be slow memory. Contiguous arrays usually traverse cache more efficiently than pointer-linked objects scattered across the heap.

When performance matters, ask:

- which fields are read together?
- which elements are processed together?
- can hot data be separated from cold data?
- can pointer chasing be replaced by indexes or handles?

## 14.14 Initialization

Allocated bytes must become valid typed values before use. Zero initialization may be enough for some types but not for types with domain invariants or embedded resources.

Distinguish:

- raw storage acquisition;
- value initialization;
- subsystem registration;
- resource ownership transfer.

## 14.15 Destruction

Destruction may involve more than releasing bytes. A type can own files, GPU objects, sockets, nested allocations, or foreign handles. Define explicit `destroy_*` procedures for resource-owning types and make them safe for partial initialization where practical.

## 14.16 Double release and use-after-free

After releasing storage, no pointers, slices, strings, or handles to that storage may be used. Clearing a pointer to `nil` can help locally, but it does not invalidate copies held elsewhere.

The real solution is architectural: limit aliases, shorten borrows, centralize ownership, and use generations for long-lived handles.

## 14.17 Worked model: frame processing

```text
Application owns World for the process lifetime
World owns entity arrays until shutdown
Frame arena owns temporary query results until frame end
Renderer borrows world data during render submission
GPU owns submitted work until the relevant synchronization point
```

Each lifetime has a different release event. Treating everything as generic heap memory would hide these distinctions.

## 14.18 Common mistakes

- assuming a copied slice owns copied elements;
- returning views into temporary storage;
- growing a container while retaining interior pointers;
- using one global allocator without lifetime categories;
- optimizing field packing before understanding access patterns;
- freeing bytes without destroying nested resources.

## 14.19 Chapter checklist

You should now be able to identify storage regions, distinguish descriptors from backing storage, describe ownership and borrowing, reason about alignment and padding, and connect memory layout to performance.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Odin core memory packages](https://pkg.odin-lang.org/core/mem/)
