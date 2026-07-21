# Threadline Engine Design

## Goals

Threadline exists to demonstrate a compact, inspectable engine architecture in idiomatic Odin. It optimizes for clarity, deterministic behavior, explicit ownership, and gradual extension.

## Non-goals

The project does not currently aim to provide a complete renderer, editor, physics engine, scripting language, networking stack, or production asset importer. Those capabilities should be added only when the corresponding boundary is understood and testable.

## Core rules

### One owner per subsystem

`App` owns the world, asset registry, renderer command buffer, and frame statistics. Subsystems do not hide process-wide singleton state.

### Stable identity through handles

Entities and assets are referenced by index-and-generation handles. Destroying a slot increments its generation, so stale handles fail validation instead of silently targeting a new object.

### Simulation does not call a graphics API

The world produces state. The render extraction phase converts visible state into `Render_Command` values. A backend may later consume those values on another thread or platform.

### Frame-local data has frame-local lifetime

The renderer command count is reset at the beginning of every frame. Commands are never treated as persistent world state.

### Capacity is explicit

The first milestone uses fixed-capacity arrays. This makes memory use and failure modes visible. Later milestones may replace selected arrays with allocator-backed storage without changing public invariants.

### Failure is represented

Creation and lookup operations return a status. Capacity exhaustion and stale handles are normal runtime conditions, not assertion failures.

### Determinism before parallelism

The initial frame pipeline runs in a fixed order:

1. begin frame;
2. update simulation;
3. extract rendering data;
4. submit commands;
5. end frame.

Jobs may parallelize stages later, but the dependency order remains explicit.

## Runtime invariants

- An entity is valid only when its slot is alive and generations match.
- Destroying an invalid entity changes nothing.
- A render command references only valid, extracted data for the current frame.
- Asset slot zero is not treated specially; validity is entirely generation-based.
- `frame_count` increments exactly once per completed frame.
- Shutdown invalidates the application's initialized state.

## Extension boundaries

Future platform and GPU implementations should live behind procedures that consume plain data. Dynamic-library boundaries must use ABI-stable types, explicit ownership, and versioned API tables.

## Testing strategy

Tests prioritize invariants rather than printed output:

- valid handles resolve;
- destroyed handles become stale;
- reused slots receive a new generation;
- fixed-step updates move live entities;
- each frame clears and rebuilds render commands;
- application lifecycle counters remain coherent.