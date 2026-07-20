# Chapter 16 — Arenas, Pools, and Temporary Memory

[← Chapter 15: Allocators and `context.allocator`](15-allocators-context.md) · [Exercises](../exercises/16-arenas-pools-temporary-memory.md) · [Chapter 17: Files, Paths, and OS Services →](17-files-paths-os-services.md)

General-purpose allocation is flexible, but many systems have stronger lifetime patterns. Arenas, pools, and temporary allocators encode those patterns directly.

## 16.1 Arena allocation

An arena serves many allocations from one or more large backing blocks. Individual values are not freed separately; the arena is reset or destroyed as a group.

This is ideal when many objects share one lifetime:

- a parsed document;
- one network request;
- one frame's scratch data;
- a level load;
- a compiler pass.

## 16.2 Why arenas are fast

The common allocation path is often little more than aligning and advancing a cursor. Cleanup is constant-time because the whole region is reclaimed together.

The larger benefit is conceptual: ownership becomes "the arena owns everything created during this phase."

## 16.3 Arena lifetime

```text
create arena
  allocate nodes
  allocate strings
  allocate tables
use all values
reset or destroy arena
all values become invalid together
```

No pointer, string, slice, or container backed by the arena may outlive the reset.

## 16.4 Reset versus destroy

Resetting retains backing blocks for reuse. Destroying releases them to the parent allocator.

Reset is useful for repeated workloads such as frames or requests. Destroy is appropriate when the subsystem itself ends or when retained peak capacity is no longer acceptable.

## 16.5 High-water marks

An arena tends to retain enough memory for its largest recent workload. Track peak usage and decide whether occasional spikes should permanently enlarge the region.

Possible policies include:

- retain all blocks;
- retain only a baseline block;
- shrink after several quiet cycles;
- use a separate overflow arena for rare spikes.

## 16.6 Temporary memory

Temporary allocators provide scoped scratch storage. A common pattern is to begin a temporary region, perform work, and end it with `defer`.

Use temporary memory for formatting, parsing intermediates, transient arrays, sort scratch space, and short-lived conversions.

Never return a view into temporary memory unless the caller consumes it before the region ends.

## 16.7 Nested temporary scopes

Temporary regions may nest if the allocator supports markers or checkpoints:

```text
frame temporary scope
  animation scratch
  renderer scratch
    text layout scratch
```

Ending an inner scope must not invalidate allocations owned by an outer scope.

## 16.8 Pools

A pool manages storage for values of one size or type. It typically maintains a free list and reuses slots.

Pools are useful for:

- particles;
- network connections;
- syntax nodes;
- physics contacts;
- stable editor objects;
- frequently created fixed-size jobs.

## 16.9 Pool benefits and costs

Benefits:

- predictable element size;
- fast allocation and release;
- reduced fragmentation;
- optional stable addresses;
- easy capacity accounting.

Costs:

- reserved but unused capacity;
- fixed maximums or growth complexity;
- stale pointer or handle risks;
- poor fit for variable-sized data.

## 16.10 Free lists

A free list stores which slots are available. Releasing a slot returns it to the list. The next allocation reuses a free slot before expanding capacity.

When external references persist, pair slot indexes with generation counters:

```odin
Handle :: struct {
    index: u32,
    generation: u32,
}
```

A handle is valid only when its generation matches the current slot generation.

## 16.11 Stable addresses versus compact storage

Pools based on fixed blocks can preserve addresses. Dense arrays are often faster to iterate but may move elements during removal.

Choose based on the dominant operation:

- stable identity and sparse access;
- dense iteration and cache locality;
- frequent creation and destruction;
- external pointer requirements.

## 16.12 Slab and size-class allocation

A slab allocator groups objects of one size. A size-class allocator routes requests into several slabs, such as 16, 32, 64, and 128 bytes.

These designs reduce fragmentation and make allocation cost more predictable, but they add internal fragmentation when requests do not exactly match a class.

## 16.13 Frame allocator pattern

A game or interactive editor often maintains two or more transient regions:

```text
frame N writes into arena A
GPU or worker still reads arena A
frame N+1 writes into arena B
synchronization confirms A is reusable
reset A
```

The reset point must respect every consumer, not merely the CPU frame boundary.

## 16.14 Request arena pattern

A server can create or reset an arena per request:

1. parse headers and body into the request arena;
2. perform validation and routing;
3. build the response;
4. send or copy required output;
5. reset the arena.

Persistent session data must be copied into a longer-lived allocator.

## 16.15 Choosing a strategy

Use a general allocator for unrelated lifetimes and simplicity. Use an arena when values die together. Use a pool when many same-sized objects are repeatedly created and destroyed. Use temporary memory for strictly scoped scratch work.

A real subsystem may combine all four.

## 16.16 Worked architecture

```text
Editor process heap
├── project arena: paths, metadata, imported settings
├── document arena per open document
├── entity pool per scene
└── temporary arena per UI frame
```

Closing a document destroys one arena. Deleting an entity returns one pool slot. Ending a frame resets temporary storage. The process heap handles unrelated long-lived objects.

## 16.17 Common mistakes

- treating arena reset as harmless while references still exist;
- returning temporary strings to long-lived callers;
- using pools for variable-sized payloads without a separate storage policy;
- assuming stable addresses from a growable contiguous pool;
- retaining a huge arena after one pathological workload;
- optimizing allocator machinery before measuring allocation patterns.

## 16.18 Chapter checklist

You should now understand bulk lifetime reclamation, arena reset policies, temporary scopes, free-list pools, generation handles, stable-address tradeoffs, and how to choose an allocation strategy from lifetime structure.

## References

- [Odin core memory package](https://pkg.odin-lang.org/core/mem/)
- [Odin package documentation](https://pkg.odin-lang.org/)
