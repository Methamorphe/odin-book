# Chapter 46 — Editor

[← Chapter 45: Runtime World](45-runtime-world.md) · [Exercises](../exercises/46-editor.md) · [Chapter 47: Profiling and Optimization →](47-profiling-optimization.md)

The editor is a client of the engine, not the owner of its internal state. It combines project data, runtime inspection, asset workflows, and commands into a productive development environment while preserving a clean boundary between authored data and live simulation.

## 46.1 Editor architecture

Separate:

- persistent project model;
- open documents;
- transient UI state;
- selection state;
- command history;
- runtime preview state;
- diagnostics and build results.

The editor may host the runtime in-process, but it should communicate through explicit services and commands.

## 46.2 Documents

Scenes, materials, settings, and scripts can be documents with:

- stable document ID;
- source path;
- dirty flag;
- current revision;
- saved revision;
- validation diagnostics;
- undo stack;
- external-change status.

Do not equate an open tab with document lifetime.

## 46.3 Commands and undo

All user edits should become commands. A command records enough data to apply and revert an operation. Continuous edits such as dragging a gizmo should coalesce into one history entry.

Commands can also drive collaboration, automation, tests, and macro recording.

## 46.4 Selection

Represent selection using stable authored IDs or validated runtime handles. Multi-selection needs a deterministic ordering and a primary item. Destroyed or reloaded objects must be removed or remapped safely.

## 46.5 Inspector

The inspector presents editable properties without becoming the data model. It should:

- show mixed values for multi-selection;
- validate before commit;
- use domain-aware controls;
- emit commands;
- expose reset and override state;
- preserve unknown serialized fields where forward compatibility matters.

## 46.6 Scene hierarchy

The hierarchy is a view of parent-child relationships and scene ownership. Reparenting must prevent cycles, preserve or intentionally change world transforms, and create an undoable command.

## 46.7 Gizmos

A transform gizmo requires stable drag capture, snapping, coordinate-space selection, and one command per completed interaction. Compute preview values during drag and commit on release.

## 46.8 Play mode

Choose a clear play-mode policy:

- clone the authored world into a temporary runtime world;
- enter simulation in the current world with a reversible snapshot;
- launch a separate process.

A cloned or separate runtime is safer. Decide whether selected runtime changes can be applied back to authored data.

## 46.9 Asset browser

The asset browser queries the asset database, not the filesystem directly. It displays import state, type, dependencies, previews, diagnostics, and references. Renames and moves should update stable metadata and references transactionally.

## 46.10 Build and diagnostics panels

Compiler, importer, shader, and runtime diagnostics should share a structured format with severity, source, location, code, and message. Clicking a diagnostic should navigate to the relevant asset or document.

## 46.11 Layout persistence

Persist docking layout, recent documents, panel visibility, and user preferences separately from project content. Version the layout format and recover gracefully from missing panels.

## 46.12 Crash resilience

Use autosave or recovery snapshots for dirty documents. Write temporary files and atomically replace the destination. Recovery data must never silently overwrite the canonical project.

## 46.13 Common mistakes

- allowing widgets to mutate engine memory directly;
- storing selection as raw pointers;
- making undo an afterthought;
- editing the runtime world as if it were authored data;
- using filesystem paths as permanent asset identity;
- saving panel layout inside project files;
- blocking the UI thread on imports or builds.

## 46.14 Chapter checklist

You should have document models, command-based edits, stable selection, inspectors, hierarchy operations, gizmos, a safe play mode, asset and diagnostic panels, persisted layout, and recovery behavior.

## References

- [Dear ImGui](https://github.com/ocornut/imgui)
- [Command pattern](https://gameprogrammingpatterns.com/command.html)
- [Model-view-controller](https://developer.mozilla.org/docs/Glossary/MVC)