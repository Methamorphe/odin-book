# Chapter 45 — Solutions

[← Exercises](../exercises/45-runtime-world.md) · [Back to chapter](../book/45-runtime-world.md)

## 1. Entity allocator

Use an index, generation array, alive array, and free list. Destruction increments generation before returning the slot.

## 2. Storage

Use dense arrays for hot universal components, sparse sets for optional data, maps for rare lookup, fixed pools for bounded transient objects, and immutable blobs for authored templates.

## 3. Structural commands

Record create, destroy, add, remove, and reparent operations in a bounded command buffer. Apply it after systems finish iteration.

## 4. Access declaration

Each system lists component sets read and written. Systems with disjoint writes and no read-after-write dependency can run in parallel.

## 5. Fixed step

Accumulate clamped frame delta, execute while accumulator exceeds the fixed interval up to a maximum step count, then retain the remainder for interpolation.

## 6. Reference remapping

First create all entities and map authored local IDs to runtime handles. In a second pass, resolve component references through that table.

## 7. Save records

Serialize stable object IDs, component type/version, and explicit fields. Asset references use stable asset IDs, never runtime handles.

## 8. Extraction

Copy transforms, bounds, and renderer handles into frame-local arrays after simulation. The renderer consumes only that snapshot.

## Challenge

The scene instance owns a set of runtime handles and a local-ID remap. Reload builds a candidate instance or applies validated patches, and unload queues destruction through the structural command path.