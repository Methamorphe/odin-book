# Chapter 41 — Architecture and Constraints

[← Chapter 40: Hot Reload and Plugin Boundaries](40-hot-reload-plugin-boundaries.md) · [Exercises](../exercises/41-architecture-constraints.md) · [Chapter 42: Platform Layer →](42-platform-layer.md)

The capstone project is a small native engine and a compact playable game. Its purpose is not to imitate a commercial engine. It exists to force every earlier lesson—memory, data layouts, handles, jobs, assets, rendering, tools, profiling, and packaging—into one coherent product.

## 41.1 Define the product

The target is a desktop application with:

- one native window;
- keyboard, mouse, and controller input;
- a simple 2D or lightweight 3D renderer;
- scene loading;
- a runtime world with stable entity handles;
- an asset registry;
- an editor mode;
- save and load support;
- deterministic development builds;
- packaged release builds.

The game should be small enough to finish: one room, one arena, one puzzle, or one short simulation loop.

## 41.2 Constraints create architecture

Write constraints before modules. Example constraints:

- target Windows, Linux, and macOS where practical;
- no allocation during the steady-state frame loop except explicitly marked temporary memory;
- all runtime objects use stable handles rather than exposed pointers;
- renderer receives commands rather than world objects;
- assets load through one registry;
- editor actions use undoable commands;
- saves use a versioned format;
- examples and core packages pass CI;
- release startup must fail with a useful diagnostic when required data is missing.

A constraint is useful only when it changes design or can be verified.

## 41.3 Layered dependency direction

A practical dependency graph is:

```text
application/game
    ↓
editor and runtime world
    ↓
renderer, assets, audio, jobs
    ↓
platform abstraction
    ↓
operating system and foreign libraries
```

Lower layers must not import higher layers. The renderer should not know about gameplay entities. The platform layer should not know about materials or scenes.

## 41.4 Engine state

Use one explicit root object:

```odin
Engine :: struct {
    platform: Platform,
    assets: Asset_Registry,
    renderer: Renderer,
    world: World,
    editor: Editor,
    running: bool,
}
```

This is not a license to create a global singleton. Pass the required subsystem or a narrow service table to procedures. The root object makes startup, shutdown, and ownership reviewable.

## 41.5 Startup and shutdown

Define startup as a transaction:

1. initialize diagnostics;
2. initialize platform services;
3. create the window and graphics context;
4. initialize jobs and temporary allocators;
5. initialize renderer and audio;
6. initialize the asset registry;
7. load project configuration;
8. create the world and editor;
9. enter the frame loop.

On failure, unwind initialized stages in reverse order. Shutdown follows the same ownership graph.

## 41.6 Frame pipeline

A minimal frame can be:

1. begin frame and reset temporary memory;
2. poll platform events;
3. build input state;
4. run fixed simulation steps;
5. update variable-rate presentation state;
6. process asset completions;
7. build render commands;
8. build editor UI;
9. submit and present;
10. collect diagnostics.

Keep the order explicit. Hidden callbacks make frame behavior difficult to profile and reproduce.

## 41.7 Fixed and variable time

Run gameplay simulation with a fixed step and rendering with interpolation. Clamp accumulated time after long stalls to avoid an unbounded catch-up spiral. Record the number of simulation steps and dropped time as diagnostics.

## 41.8 Build modes

Define at least:

- `debug`: assertions, rich diagnostics, validation, editor;
- `development`: optimization with diagnostics and hot reload;
- `release`: optimized, minimal diagnostics, no editor-only code.

Do not let build modes silently change file formats or gameplay rules.

## 41.9 Error boundaries

Classify failures:

- fatal startup failure;
- recoverable asset failure;
- invalid user project data;
- internal invariant violation;
- transient platform failure.

Each class needs a policy. A missing optional texture should not terminate the process; failure to create a graphics device usually should.

## 41.10 Definition of done

The capstone is done when a clean checkout can build, launch, load its assets, play the short game, save settings, and package a release without manual file copying. Performance budgets and known limitations must be documented.

## 41.11 Common mistakes

- starting with subsystem code before defining the game;
- creating circular package dependencies;
- exposing backend objects throughout the engine;
- treating the editor as the runtime owner;
- hiding lifetime in globals;
- postponing packaging until the end;
- optimizing without budgets or measurements.

## 41.12 Chapter checklist

You should have a written product target, verifiable constraints, dependency direction, explicit ownership root, startup/shutdown plan, frame pipeline, build modes, and completion criteria.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Game Programming Patterns](https://gameprogrammingpatterns.com/)
- [Data-Oriented Design](https://www.dataorienteddesign.com/dodbook/)