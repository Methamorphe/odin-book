# Chapter 40 — Exercises

[← Chapter](../book/40-hot-reload-plugin-boundaries.md) · [Solutions](../solutions/40-hot-reload-plugin-boundaries.md)

1. Define a versioned plugin API table using ABI-safe fields.
2. List data types that should not cross a native plugin boundary.
3. Design a persistent state header with schema version and byte size.
4. Describe a safe reload synchronization point.
5. Specify rollback behavior when a new plugin fails validation.
6. Design ownership rules for memory shared with a plugin.
7. Explain how jobs and callbacks can prevent safe unloading.
8. Create a compatibility matrix for host API and plugin versions.

## Challenge

Design a reload coordinator that compiles, stages, loads, validates, migrates, swaps, and retires plugins without losing the last known-good module.