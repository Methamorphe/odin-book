# Chapter 39 — Immediate-Mode Tools and Editor UI

[← Chapter 38: Audio and Event Systems](38-audio-event-systems.md) · [Exercises](../exercises/39-immediate-mode-tools-editor-ui.md) · [Chapter 40: Hot Reload and Plugin Boundaries →](40-hot-reload-plugin-boundaries.md)

Tools determine how quickly an engine can be understood and changed. Immediate-mode user interfaces are particularly well suited to debug panels, inspectors, profilers, and editors because the visible interface is rebuilt directly from current application state.

## 39.1 Immediate mode

An immediate-mode UI expresses widgets every frame:

```text
begin window
show transform fields
show resource status
end window
```

The UI library retains only interaction state such as focus and active IDs. The application remains the owner of domain data.

## 39.2 Stable widget identity

Labels are not always unique. Generate stable IDs from entity handles, property paths, or explicit scopes. IDs must remain consistent across frames while an interaction is active.

## 39.3 Editor architecture

Separate:

- editor application state;
- engine/runtime state;
- selection and inspection state;
- undo/redo history;
- viewport rendering;
- persistence of layouts and preferences.

Do not scatter editor-only flags through shipping runtime structures without a clear reason.

## 39.4 Selection

Selection should use stable handles. A deleted entity invalidates selection cleanly. Multi-selection can store an ordered set of handles and a primary selection.

Viewport picking can use ray tests, CPU bounds, or an ID render target. Keep picking latency and synchronization explicit.

## 39.5 Property editing

Inspectors need type metadata, validation, and transactions. Apply edits through commands rather than uncontrolled pointer mutation when changes must support undo, prefab overrides, networking, or live runtime synchronization.

```odin
Set_Position_Command :: struct {
    entity: Entity,
    before: [3]f32,
    after: [3]f32,
}
```

## 39.6 Undo and redo

An undoable command records enough information to apply and revert an operation. Group continuous drags into one transaction rather than one history entry per frame. Bound history memory and define how external changes invalidate entries.

## 39.7 Gizmos

Translation, rotation, and scale gizmos operate in local or world space. Separate visual size from world scale so handles remain usable at different camera distances. Snapping should be explicit and reversible.

## 39.8 Docking and panels

Panels should communicate through editor services and commands, not direct knowledge of one another. Typical panels include hierarchy, inspector, asset browser, console, profiler, and viewport.

## 39.9 Reflection

Odin's runtime type information can support generic inspectors, but reflection should not erase domain rules. A generic numeric editor cannot know whether a field requires clamping, units, or a resource picker. Combine reflection with metadata and custom drawers.

## 39.10 Debug UI in runtime builds

A small immediate-mode overlay is valuable for frame timing, memory, render counters, ECS inspection, and feature toggles. Gate dangerous controls and consider compile-time removal for distribution builds.

## 39.11 Persistence

Save editor layout, recent projects, key bindings, and user preferences separately from project content. Project assets should use versioned formats and atomic writes.

## 39.12 Common mistakes

- using display labels as unique widget IDs;
- mutating domain data without an undo transaction;
- storing raw pointers in selection state;
- putting editor metadata in every hot runtime structure;
- allowing panels to call one another directly;
- creating one undo entry per drag frame;
- relying on generic reflection for domain validation.

## 39.13 Chapter checklist

You should be able to design stable immediate-mode UI IDs, selection, inspectors, transactions, undo/redo, gizmos, editor panels, and runtime diagnostics.

## References

- [Dear ImGui](https://github.com/ocornut/imgui)
- [Odin Dear ImGui vendor package](https://pkg.odin-lang.org/vendor/imgui/)
- [The Immediate Mode GUI Paradigm](https://caseymuratori.com/blog_0001)
