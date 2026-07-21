# Chapter 28 — Thinking in Data Transformations

[← Chapter 27: API Design in Odin](27-api-design.md) · [Exercises](../exercises/28-thinking-in-data-transformations.md) · [Chapter 29: Cache-Aware Layouts →](29-cache-aware-layouts.md)

Data-oriented design begins by asking a different question. Instead of starting from a hierarchy of objects and methods, start from the data that must exist and the transformations that must happen to it.

This does not mean that every program should become a collection of raw arrays. It means that representation, access pattern, lifetime, and frequency are treated as first-class design constraints.

## 28.1 From nouns to transformations

An object-oriented description of a simulation may begin with nouns:

- player;
- enemy;
- projectile;
- particle;
- camera.

A data-oriented description begins with transformations:

- integrate positions from velocities;
- reduce remaining lifetimes;
- collect expired entities;
- resolve collisions;
- produce visible instances;
- serialize changed state.

The second description exposes the actual work performed each frame.

## 28.2 Identify the hot path

Not every data structure deserves aggressive optimization. Separate the program into:

- hot paths executed frequently over many elements;
- warm paths executed regularly over moderate data;
- cold paths such as configuration, menus, diagnostics, and tooling.

A clear struct-oriented API may be ideal for cold code. A dense, linear representation may be much better for a hot simulation loop.

Measure before optimizing, but design so measurement can reveal useful boundaries.

## 28.3 Inputs, outputs, and invariants

Describe a system as a transformation:

```text
positions + velocities + delta time -> updated positions
```

Then define invariants:

- the slices have equal lengths;
- delta time is non-negative;
- positions and velocities refer to the same entity ordering;
- no output aliases an input in an unsupported way.

In Odin, explicit slices and procedures make these contracts visible:

```odin
integrate :: proc(positions, velocities: []f32, dt: f32) {
    assert(len(positions) == len(velocities))
    for i in 0..<len(positions) {
        positions[i] += velocities[i] * dt
    }
}
```

## 28.4 Separate stable identity from storage position

A storage index is efficient but unstable when data is compacted. A public identity should not automatically be the same thing as an array index.

Use handles, generations, or indirection when callers need stable references. Internally, keep dense arrays where iteration performance matters.

This distinction becomes central in Chapters 30 and 31.

## 28.5 Batch work

Calling a procedure once per element is not inherently wrong, but batch-oriented APIs expose more optimization opportunities:

```odin
update_one :: proc(position: ^f32, velocity, dt: f32)
update_all :: proc(positions, velocities: []f32, dt: f32)
```

The batched form can:

- validate lengths once;
- reduce call overhead;
- improve cache locality;
- enable SIMD or multithreading later;
- collect diagnostics at the system boundary.

## 28.6 Make phases explicit

A frame can be understood as a sequence of transformations:

```text
input -> intent -> simulation -> visibility -> rendering
```

Do not allow every subsystem to mutate everything at arbitrary times. Phase boundaries simplify reasoning, testing, parallelization, replay, and debugging.

A useful rule is that each phase should have clear read sets and write sets.

## 28.7 Prefer derived data over duplicated authority

If one representation can be recomputed cheaply, avoid maintaining multiple authoritative copies.

For example:

- world transforms can be derived from local transforms and hierarchy;
- visible instances can be rebuilt from simulation state;
- UI rows can be derived from model data;
- sorted views can be rebuilt or cached with explicit invalidation.

Duplicated mutable truth produces synchronization bugs.

## 28.8 Transformation pipelines

A transformation pipeline often benefits from intermediate buffers:

```text
raw events
  -> normalized commands
  -> validated commands
  -> simulation mutations
  -> emitted events
```

Each stage can be tested independently. Temporary buffers can use frame arenas or reusable storage.

## 28.9 Determinism

Data-oriented systems frequently become easier to make deterministic because iteration order and phase order are explicit.

Determinism is valuable for:

- reproducible tests;
- replay systems;
- network synchronization;
- debugging rare failures;
- comparing optimized and reference implementations.

Avoid relying on map iteration order when order affects results.

## 28.10 Common mistakes

### Splitting every field into a separate array

Structure-of-arrays is useful when systems access only a subset of fields. It is not automatically superior for every workload.

### Optimizing cold configuration code

Complex layouts are not free. Use them where access patterns justify them.

### Hiding mutation behind broad helper APIs

A procedure that can mutate arbitrary global state prevents useful reasoning about phases and dependencies.

### Confusing compact storage with stable identity

Dense storage may move. Public references must account for that.

## 28.11 Checklist

Before implementing a data-heavy subsystem, answer:

1. What transformations run most often?
2. Which fields does each transformation read and write?
3. How many elements are processed?
4. Which data must have stable identity?
5. Which outputs can be derived?
6. Which temporary allocations can be batched or reused?
7. Does processing order affect correctness?
8. How will the system be measured?

## References

- [Odin Overview](https://odin-lang.org/docs/overview/)
- [Data-Oriented Design](https://www.dataorienteddesign.com/dodbook/)
- [Mike Acton — Data-Oriented Design and C++](https://www.youtube.com/watch?v=rX0ItVEVjHc)
