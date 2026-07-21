# Chapter 30 — Handles, Generations, and Object Pools

[← Chapter 29: Cache-Aware Layouts](29-cache-aware-layouts.md) · [Exercises](../exercises/30-handles-generations-object-pools.md) · [Chapter 31: Entity-Component Systems →](31-entity-component-systems.md)

Dense storage is efficient, but pointers and raw indexes become dangerous when elements move or slots are reused. Generational handles provide stable-looking references while allowing compact internal storage.

## 30.1 Why raw pointers fail

A pointer into a dynamic array can become invalid after reallocation. A pointer into a dense pool can refer to a different object after deletion and slot reuse. The address may still look valid while its meaning has changed.

## 30.2 Why raw indexes are insufficient

An index identifies a slot, not the lifetime occupying that slot:

```text
slot 7 contains texture A
texture A is destroyed
slot 7 is reused for texture B
old index 7 now resolves to texture B
```

This is an ABA-style lifetime bug.

## 30.3 Handle structure

A handle combines:

- an index locating a slot;
- a generation identifying the slot lifetime.

```odin
Handle :: struct {
    index: u32,
    generation: u32,
}
```

A slot stores the current generation. Resolution succeeds only when both values match.

## 30.4 Slot states

A pool commonly maintains:

- payload storage;
- generation per slot;
- alive state;
- a free-list of reusable indexes.

Creating an object either consumes a free slot or extends storage. Destroying it marks the slot dead, increments its generation, and adds the index to the free-list.

## 30.5 Generation rollover

Generation counters have finite width. With `u32`, rollover requires billions of reuse cycles for one slot, but long-running or adversarial systems should still define behavior.

Options include:

- use `u64` generations;
- reserve generation zero as invalid;
- retire a slot when the generation would wrap;
- accept the quantified risk for bounded applications.

## 30.6 Null and invalid handles

Define a clear invalid representation:

```odin
INVALID_HANDLE :: Handle{index = max(u32), generation = 0}
```

Do not treat a zeroed handle as valid unless slot zero and generation zero are intentionally excluded.

## 30.7 Dense storage plus sparse slots

A high-performance pool may separate public slots from dense payloads:

```text
handle index -> slot -> dense index -> payload
payload move -> update moved slot's dense index
```

This permits swap-delete compaction while handles remain valid.

The reverse mapping from dense index to slot index is required when moving the last payload into a removed position.

## 30.8 Resolution API

Keep handle validation centralized:

```odin
get :: proc(pool: ^Pool, handle: Handle) -> (^Item, bool)
```

Validation should check:

1. index is in range;
2. slot is alive;
3. generation matches;
4. mapped dense index is in range.

Never allow callers to bypass these checks with a public raw index.

## 30.9 Ownership and borrowing

A resolved pointer is usually a temporary borrow. Document that it may become invalid after operations that grow, compact, or destroy pool storage.

Prefer resolving a handle near the point of use rather than storing long-lived pointers.

## 30.10 Free-list design

A free-list can be represented by:

- a dynamic array of free indexes;
- a linked list encoded inside dead slots;
- a bitset and scan;
- segregated pools by type or size.

A stack of free indexes is often simple and effective.

## 30.11 Object pools versus allocators

An allocator manages bytes. An object pool manages typed lifetimes, identity, and reuse. A pool may use an allocator internally, but the abstractions solve different problems.

Pools are useful for:

- entities;
- assets;
- audio voices;
- particle emitters;
- network connections;
- editor documents;
- asynchronous request records.

## 30.12 Thread safety

A pool is not automatically thread-safe. Common strategies are:

- single-owner mutation;
- command buffers merged at a synchronization point;
- locks around structural operations;
- per-thread pools with later transfer.

Read-only handle resolution may be parallel only when no concurrent mutation can move or destroy storage.

## 30.13 Debugging support

In debug builds, store additional metadata:

- creation site;
- human-readable label;
- owning subsystem;
- destruction frame;
- high-water mark;
- failed resolution counts.

These diagnostics can turn a stale-handle crash into an actionable message.

## 30.14 Common mistakes

### Incrementing generation on creation instead of destruction

Either convention can work, but all transitions must be consistent and generation zero policy must be clear.

### Returning persistent pointers

Compaction and growth can invalidate them.

### Forgetting to update reverse mappings

Swap-delete requires updating the moved payload's slot.

### Exposing dense indexes as identity

That prevents later compaction and safe reuse.

## References

- [Odin Overview — Distinct Types](https://odin-lang.org/docs/overview/#distinct-types)
- [Bitsquid Foundation — Handles](https://bitsquid.blogspot.com/2011/09/managing-decoupling-part-4-id-lookup.html)
