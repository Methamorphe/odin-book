# Chapter 20 — Testing and Reproducible Builds

[← Chapter 19: Assertions, Diagnostics, and Logging](19-assertions-diagnostics-logging.md) · [Exercises](../exercises/20-testing-reproducible-builds.md) · [Chapter 21: Debugging and Profiling →](21-debugging-profiling.md)

Professional systems software needs more than code that compiles on one machine. It needs tests that describe behavior, build inputs that can be reproduced, and automation that detects accidental drift.

## 20.1 What a test should prove

A useful test protects an observable contract. It should answer one precise question and fail for one understandable reason.

Prefer tests for:

- parsing boundaries and malformed inputs;
- allocator and lifetime behavior;
- numerical edge cases;
- serialization compatibility;
- public package contracts;
- regressions that previously reached users.

Avoid tests that merely repeat the implementation line by line. Those tests make refactoring harder without increasing confidence.

## 20.2 Odin test procedures

Test procedures use the `@(test)` attribute and accept a testing context:

```odin
package arithmetic

import "core:testing"

add :: proc(a, b: int) -> int {
    return a + b
}

@(test)
addition_is_exact :: proc(t: ^testing.T) {
    testing.expect_value(t, add(20, 22), 42)
}
```

Run tests for a package with:

```text
odin test path/to/package
```

Keep production code and its tests close enough that ownership remains obvious. Small packages can keep tests beside implementation files; larger packages may use dedicated `_test.odin` files.

## 20.3 Arrange, act, assert

A simple structure improves diagnostics:

1. arrange the inputs and dependencies;
2. execute one meaningful operation;
3. assert the resulting contract.

Do not hide every assertion behind helper layers. Helpers should remove noise, not obscure what failed.

## 20.4 Table-driven tests

When many inputs share one behavior, represent them as data:

```odin
Case :: struct {
    input:    int,
    expected: int,
}

cases := []Case{{0, 0}, {1, 1}, {5, 25}}
for c in cases {
    testing.expect_value(t, square(c.input), c.expected)
}
```

Table-driven tests make edge cases visible and reduce duplicated setup. Include the case index or input in diagnostics when failures would otherwise be ambiguous.

## 20.5 Negative and adversarial testing

Systems code often fails at boundaries rather than normal inputs. Test:

- empty buffers;
- maximum representable lengths;
- truncated files;
- invalid enum discriminants;
- allocation failure where the API can report it;
- repeated initialization and cleanup;
- stale handles;
- overlapping or aliased memory when relevant.

A parser is not tested until malformed data is tested.

## 20.6 Determinism in tests

Tests should not depend accidentally on map iteration order, wall-clock time, process-global state, network availability, or the current working directory.

Inject volatile dependencies:

```odin
Clock :: struct {
    now: proc() -> i64,
}
```

A fake clock makes timeout behavior deterministic. The same principle applies to random generators, filesystems, allocators, and operating-system services.

## 20.7 Temporary storage and cleanup

Tests create files, allocations, threads, and handles. Pair every acquisition with cleanup using `defer`. Give each test isolated temporary state rather than sharing mutable global fixtures.

Leaked test resources are not harmless: they hide production lifetime bugs and make suites flaky.

## 20.8 Unit, integration, and compatibility tests

Use several levels deliberately:

- **unit tests** isolate one package contract;
- **integration tests** connect packages and real resources;
- **compatibility tests** preserve file formats, ABIs, protocols, or saved assets;
- **smoke tests** prove that a built executable starts and performs one critical path.

Most tests should be fast, but not every valuable test must be microscopic.

## 20.9 Reproducible builds

A reproducible build produces equivalent output from the same declared inputs. This requires controlling:

- Odin compiler version;
- target architecture and operating system;
- foreign compiler and linker versions;
- build flags and feature switches;
- generated source inputs;
- third-party library revisions;
- environment variables that influence output.

Document the supported compiler version in the repository. CI should install that version explicitly instead of silently following the newest nightly build.

## 20.10 Build metadata

Build metadata is useful, but timestamps and local paths can destroy byte-for-byte reproducibility. Prefer stable metadata such as a commit SHA and declared semantic version. Separate diagnostic provenance from deterministic program data when necessary.

## 20.11 Build modes

Use named build modes with explicit intent:

- development: fast compilation and assertions;
- test: instrumentation and deterministic settings;
- release: optimization and production diagnostics;
- profiling: symbols plus representative optimization;
- sanitizing or validation modes where the toolchain supports them.

Do not treat “release” as a mysterious bag of flags. Record the exact command.

## 20.12 CI as executable documentation

A minimal pipeline should:

1. install the pinned toolchain;
2. run formatting or style checks;
3. run `odin check` on examples and packages;
4. execute tests;
5. build supported targets;
6. preserve useful diagnostics and artifacts.

CI must run commands developers can also run locally. A pipeline that only works inside the CI service is difficult to debug.

## 20.13 Test quality checklist

Before accepting a test, ask:

- Does its name describe behavior?
- Can it run in any order?
- Does it clean up resources?
- Are failure messages actionable?
- Does it avoid hidden time, randomness, or filesystem dependencies?
- Is the asserted contract stable enough to protect?

## 20.14 Common mistakes

### Testing implementation details

Tests become brittle when they assert private call sequences instead of results.

### One enormous integration suite

A slow monolith makes failures hard to localize. Keep layered suites.

### Floating compiler versions

A nightly compiler can change syntax, diagnostics, generated code, or standard-library behavior without a repository change.

### Ignoring failed cleanup

Cleanup failures can reveal file-lock, ownership, and ordering bugs. Do not discard them automatically.

## 20.15 Chapter checklist

You should now be able to:

- write focused Odin test procedures;
- design deterministic and adversarial tests;
- distinguish unit, integration, compatibility, and smoke tests;
- pin build inputs;
- define explicit build modes;
- treat CI as a reproducible local workflow.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Odin repository](https://github.com/odin-lang/Odin)
- [Reproducible Builds](https://reproducible-builds.org/)

---

[Exercises](../exercises/20-testing-reproducible-builds.md) · [Solutions](../solutions/20-testing-reproducible-builds.md)