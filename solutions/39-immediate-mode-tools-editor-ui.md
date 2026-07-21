# Chapter 39 — Solutions

[← Exercises](../exercises/39-immediate-mode-tools-editor-ui.md) · [Back to chapter](../book/39-immediate-mode-tools-editor-ui.md)

## 1. Stable IDs

Hash a persistent panel identifier with an explicit local ID. Do not derive identity only from screen position or transient list order.

## 2. Labels and IDs

Two controls can display the same text but must retain distinct state. A label syntax or explicit ID parameter keeps presentation independent from identity.

## 3. Keyboard focus

Store one focused widget ID. A click, tab traversal, panel close, or explicit command transfers focus. Text input is routed only to the focused widget.

## 4. Drag capture

When dragging starts, store an active widget ID and initial values. Continue routing pointer movement to it until release, even outside its rectangle.

## 5. Undo

Capture the before and after transform values in a command. Coalesce continuous drag updates into one command committed on release.

## 6. Docking

Use a tree where split nodes hold orientation and ratio, and leaf nodes hold tab stacks. Persist panel identifiers rather than pointers.

## 7. Multi-edit

Show a mixed-value state when selected entities disagree. Applying a value emits one command containing every affected entity and previous value.

## 8. Frame diagnostics

Expose frame time, draw calls, command count, hovered/active/focused IDs, allocations, input events, clipping regions, and hot-reload status.

## Challenge

Keep editor models, UI transient state, persisted layout, and runtime state separate. Route all destructive edits through commands so undo, redo, validation, and collaboration can share the same boundary.