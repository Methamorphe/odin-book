# Appendix D — Exercise Index

[← Appendix C: Translation Notes](appendix-c-translation-notes.md) · [Appendix E: Further Reading →](appendix-e-further-reading.md)

This index groups the book’s exercises by skill rather than only by chapter. Use it to plan review sessions, interview preparation, or project-focused study.

## D.1 Language foundations

- [Chapter 1 exercises](../exercises/01-why-odin.md) — language goals and trade-offs.
- [Chapter 2 exercises](../exercises/02-installing-odin.md) — toolchain installation and verification.
- [Chapter 3 exercises](../exercises/03-first-program.md) — first packages, build, run, and formatting.
- [Chapter 4 exercises](../exercises/04-values-variables-constants.md) — declarations, constants, and value semantics.
- [Chapter 5 exercises](../exercises/05-primitive-and-named-types.md) — primitive, named, and distinct types.
- [Chapter 6 exercises](../exercises/06-procedures.md) — procedures, arguments, and multiple results.
- [Chapter 7 exercises](../exercises/07-control-flow.md) — branches, switches, and loops.
- [Chapter 8 exercises](../exercises/08-packages.md) — package boundaries and project organization.

## D.2 Collections and data modelling

- [Chapter 9 exercises](../exercises/09-arrays-slices-dynamic-arrays.md) — arrays, slices, capacity, and growth.
- [Chapter 10 exercises](../exercises/10-maps-strings-runes.md) — maps, UTF-8, strings, and runes.
- [Chapter 11 exercises](../exercises/11-structs-enums-unions.md) — structs, enums, unions, and state machines.
- [Chapter 12 exercises](../exercises/12-pointers-addressability.md) — pointers, invalidation, and stable references.
- [Chapter 13 exercises](../exercises/13-defer-explicit-errors.md) — cleanup and explicit error paths.

## D.3 Memory and systems programming

- [Chapter 14 exercises](../exercises/14-memory-model.md) — ownership, lifetime, layout, and borrowed views.
- [Chapter 15 exercises](../exercises/15-allocators-context.md) — allocator-aware APIs and context.
- [Chapter 16 exercises](../exercises/16-arenas-pools-temporary-memory.md) — arenas, pools, scratch memory, and generations.
- [Chapter 17 exercises](../exercises/17-files-paths-os-services.md) — files, paths, environment, and process services.
- [Chapter 18 exercises](../exercises/18-serialization-binary-layouts.md) — binary formats, validation, and versioning.
- [Chapter 19 exercises](../exercises/19-assertions-diagnostics-logging.md) — invariants, diagnostics, and structured logs.

## D.4 Professional engineering

- [Chapter 20 exercises](../exercises/20-testing-reproducible-builds.md) — tests, fixtures, deterministic builds, and CI.
- [Chapter 21 exercises](../exercises/21-debugging-profiling.md) — debugging plans, measurements, and regression evidence.
- [Chapter 22 exercises](../exercises/22-c-interoperability.md) — C ABI, layouts, strings, and ownership.
- [Chapter 23 exercises](../exercises/23-foreign-libraries-bindings.md) — raw bindings, wrappers, and dependency isolation.
- [Chapter 24 exercises](../exercises/24-threads-atomics-synchronization.md) — threads, locks, atomics, and shutdown.
- [Chapter 25 exercises](../exercises/25-simd-numerical-code.md) — scalar baselines, vector loops, tails, and tolerance.
- [Chapter 26 exercises](../exercises/26-reflection-compile-time.md) — reflection, compile-time checks, and generated behavior.
- [Chapter 27 exercises](../exercises/27-api-design.md) — ownership contracts, error surfaces, and stable APIs.

## D.5 Data-oriented design

- [Chapter 28 exercises](../exercises/28-thinking-in-data-transformations.md) — pipelines, batches, and explicit transformations.
- [Chapter 29 exercises](../exercises/29-cache-aware-layouts.md) — AoS, SoA, hot/cold splitting, and locality.
- [Chapter 30 exercises](../exercises/30-handles-generations-object-pools.md) — handles, free lists, and stale-reference protection.
- [Chapter 31 exercises](../exercises/31-entity-component-systems.md) — component storage, queries, and structural changes.
- [Chapter 32 exercises](../exercises/32-job-systems-frame-pipelines.md) — job decomposition, dependencies, and frame stages.
- [Chapter 33 exercises](../exercises/33-asset-registries-resource-lifetime.md) — asset identities, states, reloads, and lifetime.

## D.6 Graphics and game technology

- [Chapter 34 exercises](../exercises/34-window-creation-input.md) — platform events, input snapshots, and focus behavior.
- [Chapter 35 exercises](../exercises/35-rendering-fundamentals.md) — render commands, passes, synchronization, and frame ownership.
- [Chapter 36 exercises](../exercises/36-textures-meshes-materials.md) — resource formats, material data, and upload lifetime.
- [Chapter 37 exercises](../exercises/37-cameras-transforms-scenes.md) — transforms, cameras, hierarchy, and scene extraction.
- [Chapter 38 exercises](../exercises/38-audio-event-systems.md) — audio commands, event queues, and thread boundaries.
- [Chapter 39 exercises](../exercises/39-immediate-mode-tools-editor-ui.md) — stable widget identity, selection, and editor state.
- [Chapter 40 exercises](../exercises/40-hot-reload-plugin-boundaries.md) — ABI-safe plugins, migration, and safe reload points.

## D.7 Capstone engine

- [Chapter 41 exercises](../exercises/41-architecture-constraints.md) — engine constraints, subsystem ownership, and lifecycle.
- [Chapter 42 exercises](../exercises/42-platform-layer.md) — platform abstraction, events, timing, and headless support.
- [Chapter 43 exercises](../exercises/43-renderer.md) — renderer API, resource handles, frames in flight, and recovery.
- [Chapter 44 exercises](../exercises/44-asset-pipeline.md) — source assets, deterministic artifacts, manifests, and dependencies.
- [Chapter 45 exercises](../exercises/45-runtime-world.md) — runtime entities, simulation phases, and save boundaries.
- [Chapter 46 exercises](../exercises/46-editor.md) — editor commands, undo/redo, project state, and play mode.
- [Chapter 47 exercises](../exercises/47-profiling-optimization.md) — budgets, traces, counters, and optimization reports.
- [Chapter 48 exercises](../exercises/48-packaging-small-game.md) — staging, manifests, smoke tests, saves, and distribution.

## D.8 Exercises by objective

### Learn Odin syntax

Start with chapters 3–13. Complete the normal exercises before the challenges.

### Build command-line and systems tools

Focus on chapters 14–23, then 27. Add chapters 18–20 for durable formats and testing.

### Prepare for low-level performance work

Focus on chapters 12, 14–16, 21, 24, 25, 28, and 29.

### Build an ECS or simulation runtime

Focus on chapters 28–33 and 45. Revisit chapters 20, 24, and 47 for testing, concurrency, and measurement.

### Build graphics or engine technology

Complete chapters 33–48 in order. The later exercises assume the ownership and data-layout ideas developed earlier.

### Design stable native APIs

Focus on chapters 18, 22, 23, 27, 33, 40, 42, 43, and 44.

## D.9 Suggested review tracks

### One-week syntax review

- Day 1: chapters 3–5.
- Day 2: chapters 6–8.
- Day 3: chapters 9–10.
- Day 4: chapters 11–13.
- Day 5: redo one challenge without looking at the solution.
- Day 6: combine three concepts in one small package.
- Day 7: run the full example CI locally.

### Four-week systems track

- Week 1: memory, pointers, allocators, and temporary storage.
- Week 2: files, binary formats, errors, and tests.
- Week 3: C interop, bindings, concurrency, and profiling.
- Week 4: design and ship one command-line tool.

### Six-week engine track

- Week 1: data-oriented transformations and layouts.
- Week 2: handles, ECS, jobs, and assets.
- Week 3: input, rendering, resources, and scenes.
- Week 4: audio, tools, and hot reload.
- Week 5: capstone architecture through runtime world.
- Week 6: editor, profiling, packaging, and final review.

## D.10 How to use solutions

Attempt each exercise first. When blocked:

1. write down the exact invariant or API contract you cannot express;
2. inspect only the relevant solution section;
3. close it and implement independently;
4. compare ownership, error behavior, and edge cases—not only output;
5. add one additional test the solution did not include.

A solution is one valid design, not the only possible implementation.
