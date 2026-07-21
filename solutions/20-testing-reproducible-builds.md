# Chapter 20 Solutions — Testing and Reproducible Builds

[← Exercises](../exercises/20-testing-reproducible-builds.md) · [Chapter](../book/20-testing-reproducible-builds.md)

## Solution 1

```odin
package parity

import "core:testing"

is_even :: proc(value: int) -> bool { return value % 2 == 0 }

@(test) zero_is_even :: proc(t: ^testing.T) {
    testing.expect(t, is_even(0))
}

@(test) positive_even :: proc(t: ^testing.T) {
    testing.expect(t, is_even(42))
}

@(test) negative_odd :: proc(t: ^testing.T) {
    testing.expect(t, !is_even(-7))
}
```

## Solution 2

Represent expected success separately from the expected value. Each case should include a name so a failing row is identifiable. The parser must reject empty input, trailing characters, and values outside the chosen integer range.

## Solution 3

Store a `now: proc() -> i64` dependency in the cache or pass it to expiration checks. The test advances a fake integer timestamp directly. This removes sleeps, scheduler noise, and slow tests.

## Solution 4

Use a failing or budget allocator. After failure, the result must either be empty or contain only fully initialized elements; all successfully acquired temporary memory must be released. Never return a partially initialized owning container without documenting that state.

## Solution 5

Keep the version-1 byte array in the repository. Decode it and assert every semantic field, not the private decoder steps. This fixture protects compatibility even after the internal parser changes.

## Solution 6

One acceptable policy:

- development: symbols and assertions, low optimization;
- test: symbols, assertions, deterministic settings;
- profiling: symbols and release-like optimization;
- release: full supported optimization and production diagnostics.

The exact commands belong in a script or task file so CI and local developers use the same entrypoint.

## Solution 7

Pin the Odin revision, native compiler or linker image, third-party source revisions, generation commands, and target flags. Remove wall-clock timestamps and absolute source paths from deterministic output or place them in a separate provenance file.

## Solution 8

The CI job should check out the repository, install the exact compiler revision, execute the same `check`, `test`, and `build` script used locally, and upload the resulting artifact. Matrix jobs may add supported operating systems after the single path is reliable.

## Challenge notes

The fake clock owns a mutable timestamp; deterministic random uses a fixed seed and explicit state; the temporary directory helper creates a unique test-owned path and removes it with `defer`; the counting allocator records allocation count, bytes, and leaks. Helpers should not introduce process-global mutable state.