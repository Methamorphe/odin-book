# Threadline Engine

Threadline is the book's longitudinal project: a deliberately small Odin game-runtime skeleton that grows from the foundations into the capstone architecture.

It is not intended to compete with a production engine. Its purpose is to keep one coherent codebase visible while the book introduces packages, explicit lifetime, handles, data-oriented storage, frame pipelines, assets, rendering, tooling, profiling, and packaging.

## Current vertical slice

The initial version already contains:

- an explicit application lifecycle;
- a deterministic fixed-step frame loop;
- a world backed by fixed-capacity arrays;
- generational entity handles that reject stale references;
- transform updates over dense data;
- a renderer-facing command buffer;
- a small asset registry with stable handles;
- frame counters and lightweight profiling statistics;
- unit tests for entity lifetime and frame execution.

No external graphics or audio library is required yet. This keeps the project portable and lets the repository CI validate the architecture before platform backends are introduced.

## Run it

From the repository root:

```bash
odin run projects/engine
```

Run the tests:

```bash
odin test projects/engine
```

Validate without producing an executable:

```bash
odin check projects/engine
```

## What the demo does

The executable initializes the engine, registers two assets, creates two entities, runs five deterministic frames, emits renderer commands, destroys one entity, and demonstrates that its old handle no longer resolves.

The output is textual on purpose. Rendering commands are data. A future platform backend can consume the same command buffer without changing the simulation.

## Reading order

1. `types.odin` — shared value and handle types.
2. `world.odin` — generational entities and dense transform data.
3. `assets.odin` — stable asset identity and registry ownership.
4. `renderer.odin` — frame-local render command generation.
5. `app.odin` — subsystem ownership and frame pipeline.
6. `main.odin` — composition root and executable demo.
7. `engine_test.odin` — executable invariants.

See [ROADMAP.md](ROADMAP.md) for the chapter-by-chapter evolution and [DESIGN.md](DESIGN.md) for the architectural rules.