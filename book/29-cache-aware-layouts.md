# Chapter 29 — Cache-Aware Layouts

[← Chapter 28: Thinking in Data Transformations](28-thinking-in-data-transformations.md) · [Exercises](../exercises/29-cache-aware-layouts.md) · [Chapter 30: Handles, Generations, and Object Pools →](30-handles-generations-object-pools.md)

Modern processors are fast at arithmetic and comparatively slow at waiting for memory. Cache-aware design arranges data so the processor receives useful bytes with fewer misses and less wasted bandwidth.

## 29.1 Locality matters

Two forms of locality dominate:

- **spatial locality**: nearby memory is accessed together;
- **temporal locality**: recently used memory is accessed again soon.

Linear iteration over a dense array typically provides strong spatial locality. Pointer-heavy graphs often do not.

## 29.2 Cache lines and useful bytes

Processors fetch memory in cache-line-sized blocks rather than one field at a time. When a loop reads only `position` from a large struct containing names, callbacks, metadata, and rarely used state, most transferred bytes are irrelevant.

The key question is not merely “is the data contiguous?” but “what fraction of each fetched cache line is useful to this loop?”

## 29.3 Array of structs

An array-of-structs layout groups all fields for one record:

```odin
Particle :: struct {
    position: [3]f32,
    velocity: [3]f32,
    lifetime: f32,
    color: u32,
}

particles: []Particle
```

AoS works well when systems commonly consume most fields of each record together.

Advantages:

- simple representation;
- convenient per-record access;
- easy serialization when the format is explicit;
- good locality for operations using whole records.

## 29.4 Structure of arrays

A structure-of-arrays layout groups each field separately:

```odin
Particles :: struct {
    positions: [dynamic][3]f32,
    velocities: [dynamic][3]f32,
    lifetimes: [dynamic]f32,
    colors: [dynamic]u32,
}
```

SoA works well when hot loops use only selected fields. An integration system can stream through positions and velocities without loading colors or unrelated metadata.

Advantages:

- improved useful-byte ratio;
- natural batching;
- easier SIMD vectorization;
- independent storage policies per field.

Costs:

- more complex insertion and removal;
- length invariants across arrays;
- less convenient whole-record access;
- more bookkeeping.

## 29.5 Hybrid layouts

Real systems often use hybrids:

- hot fields in dense arrays;
- cold metadata in a separate table;
- chunks containing small SoA blocks;
- handles linking simulation data to editor or asset metadata.

Avoid false binary choices. Layout should follow access patterns.

## 29.6 Hot and cold splitting

Suppose an entity record contains transform data used every frame and a debug name used only in tools. Split them:

```text
Hot entity data: position, rotation, scale, flags
Cold entity data: name, source path, annotations
```

The hot loop becomes denser while tooling retains expressive metadata.

## 29.7 Alignment and padding

Struct fields may include padding to satisfy alignment requirements. Field ordering can affect size, but minimizing struct size blindly is not always the goal.

Inspect `size_of`, `align_of`, and actual access patterns. A smaller struct that causes awkward loads or false sharing may perform worse.

Never serialize a native struct by assuming its padding is stable across compiler versions, targets, or ABIs.

## 29.8 Traversal order

Layout and traversal order must agree. A row-major image buffer should usually be processed row by row. Iterating columns first can cause larger strides and more cache misses.

The same principle applies to:

- grids;
- matrices;
- terrain tiles;
- animation samples;
- audio buffers;
- component chunks.

## 29.9 Prefetching and predictability

Hardware prefetchers recognize regular access patterns. Dense forward iteration is easy to predict. Random pointer chasing is not.

Before adding explicit prefetch instructions, improve the representation and traversal order. Manual prefetching is advanced and workload-specific.

## 29.10 False sharing

Two threads updating different values can still interfere if those values occupy the same cache line. This is false sharing.

Typical mitigations include:

- partitioning output ranges;
- giving workers separate counters or scratch buffers;
- padding highly contended per-thread state;
- reducing shared writes in hot loops.

Measure before adding padding everywhere.

## 29.11 Compaction and removal

Dense arrays support fast iteration. Removal can use swap-delete when order is unimportant:

```text
replace removed slot with last element
shorten array by one
update moved element's index mapping
```

Stable ordering requires different trade-offs, such as tombstones, deferred compaction, or ordered shifting.

## 29.12 Benchmark the transformation

Microbenchmarks should model the real access pattern:

- realistic element counts;
- realistic fields read and written;
- warm-up where appropriate;
- optimized builds;
- repeated runs;
- validation that the compiler cannot eliminate the work.

Benchmark AoS versus SoA for the actual system, not for a synthetic identity loop.

## 29.13 Common mistakes

### Treating SoA as a universal rule

If nearly every operation needs the complete record, AoS may be clearer and equally effective.

### Ignoring maintenance cost

A layout that saves little time but doubles complexity is not a win.

### Measuring debug builds

Debug-mode timing can obscure memory-layout effects.

### Optimizing size without inspecting access

Cache-aware design is about useful transfers and predictable traversal, not merely small structs.

## References

- [Odin Overview — Arrays and Slices](https://odin-lang.org/docs/overview/#arrays)
- [Data-Oriented Design](https://www.dataorienteddesign.com/dodbook/)
- [What Every Programmer Should Know About Memory](https://people.freebsd.org/~lstewart/articles/cpumemory.pdf)
