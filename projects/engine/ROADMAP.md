# Threadline Engine Roadmap

The project is organized as a sequence of architectural milestones. Each milestone reuses earlier code instead of replacing it with an unrelated sample.

## Milestone 1 — Executable foundation

**Chapters 1–13**

- project package and composition root;
- named types and explicit procedures;
- fixed-capacity collections;
- lifecycle and cleanup rules;
- assertions for programmer errors.

The current `main.odin` and `types.odin` establish this foundation.

## Milestone 2 — Memory and persistence

**Chapters 14–19**

Planned additions:

- permanent and frame allocators;
- temporary arenas;
- platform-independent file access;
- versioned world serialization;
- structured diagnostics.

The fixed-capacity implementation remains available as the simplest reference configuration.

## Milestone 3 — Professional runtime

**Chapters 20–27**

Planned additions:

- broader unit and integration tests;
- reproducible build metadata;
- profiling zones;
- a narrow C-backed platform adapter;
- worker threads and synchronization;
- explicit public package APIs.

## Milestone 4 — Data-oriented world

**Chapters 28–33**

The initial project already introduces:

- generational entity handles;
- dense transform updates;
- frame command buffers;
- stable asset handles;
- subsystem-owned lifetime.

Future iterations add component masks, sparse lookup, free lists, jobs, dependency-aware assets, and deferred destruction.

## Milestone 5 — Graphics and tools

**Chapters 34–40**

Planned additions behind stable interfaces:

- real window and input backend;
- GPU renderer consuming `Render_Command` values;
- texture, mesh, and material resources;
- camera and scene traversal;
- audio command queue;
- immediate-mode debug tools;
- reload-safe game module boundary.

## Milestone 6 — Shippable capstone

**Chapters 41–48**

Planned final form:

- explicit platform, renderer, asset, world, editor, and game packages;
- headless runtime mode;
- cooked asset pipeline;
- undoable editor commands;
- performance budgets and reports;
- deterministic release staging;
- save migration and package manifest;
- a small playable game.

## Snapshot policy

The main project should remain readable as one evolving implementation. Tagged snapshots or milestone branches may later preserve important intermediate states, but duplicated chapter directories should not become the primary source of truth.

Every milestone must keep these commands green:

```bash
odin check projects/engine
odin test projects/engine
odin run projects/engine
```