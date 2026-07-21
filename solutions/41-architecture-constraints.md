# Chapter 41 — Solutions

[← Exercises](../exercises/41-architecture-constraints.md) · [Back to chapter](../book/41-architecture-constraints.md)

## 1. Product target

A good target is narrow: “Build a desktop arena game with one level, deterministic fixed-step simulation, hot-reloadable assets, and a packaged release.”

## 2. Constraints

Examples: no steady-state general allocation, stable handles across subsystems, renderer never reads ECS storage directly, assets load only through the registry, saves are versioned, editor changes are undoable, release data is manifest-driven, CI checks examples, startup failures are diagnostic, and shutdown is leak-free.

## 3. Dependencies

Application depends on editor/runtime; those depend on renderer/assets/audio/jobs; those depend on the platform layer. No reverse imports.

## 4. Engine ownership

The root owns subsystem state and initializes and destroys it in dependency order. Procedures receive narrow subsystem pointers rather than using globals.

## 5. Startup rollback

Track the last successful stage and unwind in reverse. A renderer failure destroys the window and platform state but does not call shutdown on uninitialized systems.

## 6. Frame pipeline

Poll events, update input, run fixed simulation, process completions, extract render data, build UI, submit, present, collect metrics, and reset frame-local memory.

## 7. Build modes

Debug enables assertions and validation; development combines optimization with diagnostics and hot reload; release removes editor-only code while preserving essential error reporting.

## 8. Completion

A clean checkout builds, runs the full game loop, saves settings, packages without manual copying, meets documented budgets, and includes known limitations.

## Challenge

The ADR should state context, chosen boundary, rejected alternatives, consequences, and validation criteria. It should make ownership and dependency direction explicit.