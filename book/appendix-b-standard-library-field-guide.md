# Appendix B — Standard-Library Field Guide

[← Appendix A: Odin Syntax Reference](appendix-a-odin-syntax-reference.md) · [Appendix C: Translation Notes →](appendix-c-translation-notes.md)

Odin’s standard library is organized by packages rather than by one universal framework. This appendix maps common engineering tasks to the packages you should inspect first.

## B.1 How to explore the library

Use three complementary approaches:

1. browse the package index at `pkg.odin-lang.org`;
2. search the local Odin checkout for procedure names and types;
3. read package source when ownership, allocation, or error behavior matters.

Treat signatures as the starting point, not the whole contract. Read comments around procedures that return memory, expose views, or depend on `context`.

## B.2 `core:fmt`

Use `core:fmt` for formatted output, diagnostics, and string formatting.

Typical operations:

```odin
fmt.println("value:", value)
fmt.printf("count=%d\n", count)
text := fmt.tprintf("asset-%d", id)
```

Questions to check:

- does the formatting procedure allocate?
- which allocator does it use?
- is the output intended for users, logs, or debugging?

Avoid building high-frequency logs through repeated temporary allocations.

## B.3 `core:strings`

Use `core:strings` for search, comparison, splitting, trimming, builders, and text transformations.

Remember that an Odin `string` is immutable borrowed byte data. A substring may refer to the original backing memory. Copy when the result must outlive the source.

Use a builder for repeated concatenation instead of creating many intermediate strings.

## B.4 `core:strconv`

Use `core:strconv` for numeric parsing and formatting when you need more control than general formatting.

Parsing should distinguish:

- invalid syntax;
- overflow;
- partial consumption;
- accepted bases and separators.

At configuration and file boundaries, return diagnostics that include the source location and offending field.

## B.5 `core:os`

`core:os` provides files, directories, environment access, process-level services, and platform abstractions.

Typical file lifecycle:

```odin
file, err := os.open(path)
if err != nil {
    return
}
defer os.close(file)
```

For entire-file helpers, check the current signature: modern versions generally require an allocator and return an explicit error.

Use platform user-data directories for saves and settings. Do not write beside the executable by default.

## B.6 `core:path/filepath`

Use path procedures instead of joining paths with string concatenation.

Key concerns:

- platform separators;
- normalization;
- extension handling;
- relative versus absolute paths;
- traversal outside an allowed root;
- symbolic links when enforcing security boundaries.

A normalized textual path is not automatically a secure canonical path.

## B.7 `core:io`

Use `core:io` abstractions for stream-oriented reading and writing. Stream APIs make it possible to support files, memory, pipes, compression, sockets, and test doubles through similar contracts.

Always handle partial reads and writes. “Some bytes transferred” is not equivalent to complete success.

## B.8 `core:bufio`

Buffered I/O reduces system-call overhead for many small operations. It is useful for text formats, logs, importers, and protocol parsing.

Flush explicitly at ownership boundaries and during orderly shutdown. Define what happens when flushing fails.

## B.9 `core:encoding/*`

Encoding packages cover formats such as JSON, CSV, base64, hexadecimal, and binary helpers.

Use them for interchange formats, but keep a domain layer above them:

```text
bytes → parser representation → validated domain value
```

Do not let format-specific optionality and naming leak across the whole program.

## B.10 JSON

JSON is appropriate for configuration, tooling metadata, manifests, and debugging interfaces. It is less suitable for large runtime assets or high-frequency save snapshots without careful measurement.

Define policies for:

- unknown fields;
- missing fields;
- duplicate keys;
- numeric range;
- schema version;
- deterministic output.

## B.11 Binary encoding

For binary files, write fields explicitly in a documented byte order. Do not dump arbitrary structs directly.

A robust reader validates:

- magic;
- version;
- lengths before allocation;
- offsets before slicing;
- integer overflow;
- checksums where corruption matters.

## B.12 `core:mem`

`core:mem` contains allocator and memory utilities. Use it when implementing arenas, pools, temporary allocators, layout-sensitive systems, and foreign ownership wrappers.

Important design questions:

- who chooses the allocator?
- who frees the returned memory?
- can the operation fail?
- what is the lifetime of the result?
- is alignment sufficient for the target type?

Keep allocator symmetry visible in APIs.

## B.13 Temporary allocation

Scratch or temporary allocators work well for one operation, one frame, one parser pass, or one job. They are dangerous when a returned slice or string escapes the reset point.

Document borrowed temporary results clearly. Prefer a caller-provided destination or allocator when ownership must cross a boundary.

## B.14 `core:math`

Use `core:math` for scalar numerical functions and constants. Decide whether your domain expects `f32` or `f64` and avoid silent precision drift across subsystems.

For game and graphics code, document:

- angle units;
- coordinate handedness;
- matrix convention;
- normalization assumptions;
- tolerance policy.

## B.15 `core:math/linalg`

Linear-algebra packages provide vectors, matrices, and quaternions. They are useful for transforms, cameras, geometry, and simulation.

Do not treat math types as a scene architecture. Keep hierarchy, dirty propagation, interpolation, and ownership in dedicated systems.

## B.16 `core:simd`

SIMD helpers expose vector operations and extraction. Use SIMD after profiling and keep a scalar reference implementation for verification.

A production SIMD loop normally needs:

- a vectorized body;
- a scalar tail;
- alignment-safe loads or explicit unaligned behavior;
- numerical-equivalence tests;
- architecture-aware benchmarks.

## B.17 `core:time`

Use monotonic time for durations, frame pacing, timeouts, and profiling. Wall-clock time can jump because of synchronization or user changes.

Keep separate concepts for:

- real elapsed time;
- simulation time;
- fixed-step time;
- presentation interpolation;
- calendar timestamps.

## B.18 `core:thread`

Thread packages provide thread creation and synchronization building blocks. Prefer a small number of owned threads or a job system over unbounded thread creation.

Define:

- shutdown ordering;
- ownership of thread arguments;
- how errors reach the owner;
- whether context must be initialized;
- which subsystem may block.

## B.19 `core:sync`

Synchronization packages include mutexes, condition variables, atomics, and related primitives.

Choose the highest-level primitive that expresses the invariant. Atomics are not automatically faster or safer than a lock.

For every shared value, document:

- the protecting lock or atomic protocol;
- legal readers and writers;
- lifetime and shutdown behavior;
- memory-ordering assumptions if atomics are used.

## B.20 `core:testing`

Odin tests use procedures marked with `@(test)` and a `^testing.T` parameter.

```odin
@(test)
addition_test :: proc(t: ^testing.T) {
    testing.expect_value(t, 2 + 2, 4)
}
```

Good test packages cover:

- normal behavior;
- boundaries;
- malformed input;
- allocation failure where practical;
- stale handles and invalid generations;
- deterministic replay;
- serialization round trips.

## B.21 `core:log`

Use structured logging around subsystem boundaries and state transitions. Avoid logging every iteration of a hot loop.

A useful record contains:

- severity;
- subsystem;
- stable event name;
- relevant identifiers;
- concise human message;
- build or correlation identity when needed.

Never place secrets or unnecessary personal data in logs.

## B.22 `core:reflect`

Reflection is useful for editor property views, serializers, diagnostics, and tooling. Keep reflection at boundaries rather than replacing normal typed code everywhere.

Reflection-based systems still need explicit policies for:

- field inclusion;
- versioning;
- ownership;
- validation;
- renamed fields;
- unsupported types.

## B.23 `core:dynlib`

Dynamic-library facilities support plugin loading and hot reload. Resolve one versioned API entry point rather than many unrelated symbols.

Never unload a library while callbacks, jobs, or stored procedure pointers can still enter its code.

## B.24 `core:net`

Networking packages expose sockets and protocol support. Treat network input as hostile:

- bound lengths;
- validate state transitions;
- use timeouts;
- handle partial transfer;
- limit concurrent resources;
- separate parsing from domain mutation.

## B.25 `vendor:*`

The vendor collection contains bindings and integrations distributed with Odin. Availability and exact package names may vary with the compiler release.

Keep vendor usage behind your own wrapper package so application code does not depend directly on unstable binding details.

## B.26 Package-selection checklist

Before adopting a package, answer:

1. What memory does it allocate?
2. Which allocator is used?
3. What owns returned slices and strings?
4. How are errors represented?
5. Is the API deterministic?
6. Is it safe on multiple threads?
7. Is the package stable across the Odin version pinned by CI?
8. Does it expose platform-specific behavior?
9. Can it be tested without global state?

## B.27 Recommended wrapper pattern

```text
application domain
    ↓
project-owned package
    ↓
core or vendor package
```

The project-owned layer translates errors, owns allocation policy, isolates version churn, and exposes domain-specific names.

## References

- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin source repository](https://github.com/odin-lang/Odin)
