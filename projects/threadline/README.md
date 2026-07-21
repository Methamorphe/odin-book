# Threadline Engine — Full Longitudinal Project

Threadline is the full capstone implementation for *The Odin Programming Book*. It is a dependency-free, headless-first game engine written in Odin. The engine keeps platform, rendering, audio, assets, world state, editor commands, serialization, and profiling behind explicit data boundaries so every subsystem can be studied and tested without a native window or GPU.

The earlier `projects/engine/` directory remains the first vertical slice. This directory is the expanded engine.

## Goals

- explicit ownership and bounded storage;
- deterministic fixed-step simulation;
- stable generational handles;
- dense component iteration;
- render-command extraction separated from execution;
- deterministic asset artifacts and manifests;
- editor commands with undo and redo;
- versioned save data;
- headless software rendering for CI;
- replayable input and simulation;
- measurable frame budgets;
- clean startup, failure, and shutdown paths.

## Build

```bash
odin run projects/threadline
odin check projects/threadline
odin test projects/threadline
```

The executable runs a deterministic sample game, emits frame and world statistics, renders to an in-memory framebuffer, verifies stale-handle behavior, serializes a save snapshot, and exits cleanly.

## Subsystems

| File | Responsibility |
|---|---|
| `main.odin` | executable demonstration and lifecycle |
| `core.odin` | common types, IDs, errors, hashing, fixed strings |
| `memory.odin` | arenas, scratch memory, fixed pools, diagnostics |
| `containers.odin` | bounded vectors, queues, maps, slot maps |
| `platform.odin` | time, paths, events, headless platform services |
| `input.odin` | raw input, actions, bindings, recording, replay |
| `assets.odin` | IDs, states, manifests, dependencies, loading |
| `render.odin` | handles, command buffers, software backend |
| `world.odin` | entities, components, systems, scenes |
| `physics.odin` | integration, bounds, broad-phase pairs |
| `audio.odin` | bounded audio commands and offline mixing |
| `editor.odin` | selection, commands, undo/redo, play mode |
| `serialization.odin` | versioned save writer, reader, migration |
| `profiler.odin` | counters, frame scopes, budget reports |
| `game.odin` | sample game rules and deterministic scenario |
| `tests.odin` | subsystem and integration invariants |

## Book progression

- Chapters 1–13 establish the executable, data types, packages, procedures, containers, and cleanup.
- Chapters 14–19 add explicit memory, arenas, files, serialization, diagnostics, and logs.
- Chapters 20–27 add tests, profiling, foreign boundaries, jobs, compile-time support, and API rules.
- Chapters 28–33 add data-oriented world storage, handles, ECS-style systems, frame stages, and assets.
- Chapters 34–40 add input, renderer commands, scenes, audio, editor tools, and reload boundaries.
- Chapters 41–48 integrate the engine, profile it, serialize it, and package the sample game.

## Non-goals

Threadline intentionally avoids a native graphics API, third-party UI toolkit, scripting runtime, and production asset importers. Those are replaceable backends. The project concentrates on architecture, ownership, determinism, and testable runtime behavior.

## Invariants

1. External references use handles, not long-lived pointers.
2. A stale handle never resolves to a reused object.
3. Fixed-step simulation consumes deterministic inputs.
4. Renderer and audio backends consume commands; they do not own gameplay state.
5. Temporary memory is reset only at documented synchronization points.
6. Save data is versioned and validated before mutation.
7. Editor history stores commands, not pointers into unstable arrays.
8. Capacity failure is explicit and never silently overwrites live state.
9. Hot paths avoid allocation after initialization.
10. Shutdown occurs in reverse ownership order.
