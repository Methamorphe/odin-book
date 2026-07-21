# Chapter 40 — Hot Reload and Plugin Boundaries

[← Chapter 39: Immediate-Mode Tools and Editor UI](39-immediate-mode-tools-editor-ui.md) · [Exercises](../exercises/40-hot-reload-plugin-boundaries.md) · [Chapter 41: Architecture and Constraints →](41-architecture-constraints.md)

Hot reload can shorten iteration time dramatically, but it creates a long-lived process in which code, data layouts, and resource ownership change independently. A successful design begins with explicit plugin boundaries rather than ad hoc dynamic-library calls.

## 40.1 Reloadable code

A reload cycle usually performs:

1. compile a new dynamic library;
2. copy or rename it to avoid file locking;
3. load the new library;
4. resolve a known entry point;
5. validate an API version;
6. migrate or reuse persistent state;
7. switch active function pointers;
8. unload the old library when safe.

The host process must survive a failed build or incompatible plugin.

## 40.2 A versioned API table

Expose one stable entry point that returns a table of procedures:

```odin
Plugin_API :: struct {
    abi_version: u32,
    init: proc "c" (host: ^Host_API, state: rawptr) -> bool,
    update: proc "c" (state: rawptr, dt: f32),
    shutdown: proc "c" (state: rawptr),
}
```

A table makes compatibility checks and optional extensions easier than resolving many unrelated symbols.

## 40.3 ABI-safe boundaries

Across a dynamic-library boundary, prefer:

- fixed-width scalar types;
- plain structs with documented layout;
- opaque handles;
- pointer-plus-length pairs;
- C calling conventions;
- explicit ownership rules.

Avoid passing language-internal containers, allocator state, closures, or structures whose layout may change unexpectedly.

## 40.4 Persistent state

Reloadable code should not own the only copy of persistent state. The host can allocate a state block and pass it to the plugin. State should contain stable representations or be migrated between schema versions.

Separate durable simulation state from temporary caches and function pointers. Rebuild caches after reload.

## 40.5 State migration

Add a schema version to persistent state. When layouts change, migrate explicitly:

```text
version 1 → version 2 → version 3
```

For development-only hot reload, resetting incompatible state may be acceptable. For saved projects and user data, migration must be tested and durable.

## 40.6 Host services

The plugin should request services through a host API table: logging, allocation, assets, jobs, rendering commands, and diagnostics. This avoids linking the plugin directly against the host's internal symbols.

## 40.7 Ownership

Every allocation crossing the boundary needs a matching owner. Prefer “allocate and free on the same side.” When the host supplies memory, it should also supply the procedure used to release it.

Never unload a library while callbacks, worker jobs, or objects still contain pointers into its code.

## 40.8 Safe reload points

Reload only at a synchronization point where:

- no plugin job is executing;
- no callback can enter old code;
- command queues are drained or versioned;
- rendering and audio have released old function pointers;
- persistent state is in a valid checkpoint.

A frame boundary is often a convenient reload point.

## 40.9 Failure handling

Keep the previous plugin active until the new one loads and validates successfully. Report compiler output inside the editor. A failed reload should degrade iteration, not terminate the process.

## 40.10 Plugins beyond hot reload

The same boundary can support optional importers, editor extensions, game modules, scripting runtimes, or platform backends. Do not make every engine subsystem a plugin. Use dynamic boundaries only where deployment or iteration benefits justify complexity.

## 40.11 Security

A native plugin executes with the host's privileges. Only load trusted binaries. Validate paths, avoid automatically loading files from writable untrusted locations, and consider process isolation for third-party extensions.

## 40.12 Common mistakes

- passing dynamic arrays directly across the ABI;
- storing plugin function pointers after unload;
- reloading while plugin jobs are active;
- changing state layouts without a version;
- allocating on one side and freeing on the other with a different allocator;
- replacing the old plugin before validating the new one;
- treating untrusted native plugins as sandboxed.

## 40.13 Chapter checklist

You should be able to define a versioned plugin API, design ABI-safe data, manage persistent state, migrate schemas, coordinate safe reload points, and recover from failed reloads.

## References

- [Odin foreign system](https://odin-lang.org/news/binding-to-c/)
- [Microsoft dynamic-link libraries](https://learn.microsoft.com/windows/win32/dlls/dynamic-link-libraries)
- [POSIX `dlopen`](https://pubs.opengroup.org/onlinepubs/9699919799/functions/dlopen.html)
