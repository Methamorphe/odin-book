# Chapter 40 — Solutions

[← Exercises](../exercises/40-hot-reload-plugin-boundaries.md) · [Back to chapter](../book/40-hot-reload-plugin-boundaries.md)

## 1. API table

Use fixed-width versions, opaque handles, pointer-length pairs, and `proc "c"` entries. Validate both the table size and ABI version before use.

## 2. Unsafe boundary types

Avoid dynamic arrays, maps, strings with ambiguous ownership, closures, allocator internals, polymorphic values, and pointers to temporary storage.

## 3. State header

Store a magic value, schema version, byte size, alignment, and optional checksum before the persistent payload. Migration code validates this header before reading fields.

## 4. Reload point

Pause plugin job submission, wait for in-flight jobs and callbacks, drain commands that reference old code, checkpoint persistent state, then perform the swap at a frame boundary.

## 5. Rollback

Load and validate the candidate without replacing the active module. Only swap after all checks and migration succeed. Otherwise unload the candidate and keep the old module active.

## 6. Ownership

Allocate and free on the same side. When memory must cross the boundary, expose host allocation and release callbacks and document lifetime explicitly.

## 7. Jobs and callbacks

Their instruction pointers may reference the old library. Unloading it while they execute or remain queued creates immediate use-after-unload failures.

## 8. Compatibility

Define supported host API ranges and plugin ABI versions. Reject unknown major versions; allow optional trailing fields when table size and feature flags permit.

## Challenge

A reliable coordinator uses staging filenames, a last-known-good module, candidate validation, schema migration, quiescence barriers, atomic API-table replacement, deferred unloading, and editor-visible compiler diagnostics.