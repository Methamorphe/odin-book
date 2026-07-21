# Interactive Solutions Workbook

This document is the canonical companion to [`exercises/INTERACTIVE_WORKBOOK.md`](../exercises/INTERACTIVE_WORKBOOK.md). It does not prescribe one exact implementation. It provides a concrete reference architecture, observable behavior, tests, invariants, and completion criteria for all five levels of every chapter.

## How to use these solutions

1. Finish a level before reading its solution notes.
2. Compare behavior and invariants before comparing syntax.
3. Keep parsing separate from state mutation.
4. Make every user-controlled failure return an explicit error.
5. Run the same transcript twice and compare final state at Level 5.

A complete chapter solution should support:

```text
help
demo
reset
stats
verify
save <path>
load <path>
replay <path>
quit
```

The shared shell can be organized around:

```odin
Command_Result :: enum { Ok, Invalid_Command, Invalid_Argument, Capacity, IO_Error, Corrupt_Data }

Session_Stats :: struct {
    accepted: u64,
    rejected: u64,
    operations: u64,
    current_count: int,
    peak_count: int,
}
```

`execute_line` parses one line and delegates to testable procedures. `main` owns only the input loop and presentation.

---

## Part I — Foundations

### 1 — Project evaluator

**State:** fixed-capacity array of `Project_Evaluation {name, latency_ms, memory_mb, requires_ffi, score, recommendation}`.

**Core procedures:** `evaluate_project`, `compare_projects`, `classify_score`, `find_by_name`.

**Reference rule:** reject negative budgets; score latency and memory against explicit thresholds; add an FFI suitability bonus only when FFI is required. Never hide the thresholds.

**Tests:** zero budgets, duplicate names, contradictory constraints, stable tie-breaking, full capacity, compare unknown project.

**Verify:** every stored score recomputes to the same value and every recommendation matches its score range.

### 2 — Toolchain doctor

**State:** array of checks with name, status, observed value and explanation.

**Core procedures:** `run_check`, `check_version`, `check_executable`, `explain_check`.

Inject an environment adapter so tests do not depend on the real workstation. A fake adapter returns compiler paths and versions.

**Tests:** missing compiler, wrong version, formatter absent, empty PATH, repeated checks, deterministic ordering.

**Verify:** no duplicate check names and totals equal passed + failed.

### 3 — Interactive greeter

**State:** selected style and counters per style.

`greet(name, style)` rejects trimmed empty names. `plain` returns `Hello, <name>.`; `loud` uppercases ASCII safely while preserving non-ASCII bytes.

**Tests:** blank input, accents, emoji, repeated greetings, style change, unknown style.

**Verify:** total greetings equals the sum of style counters.

### 4 — Unit converter

**State:** precision and counters per conversion mode.

Use named conversion procedures: `c_to_f`, `f_to_c`, `km_to_miles`, `miles_to_km`. Parse the mode into an enum before conversion.

**Tests:** negative temperature, zero, invalid mode, precision -1 and 7, round-trip tolerance, malformed number.

**Verify:** precision is in `0..6` and accepted conversion count equals per-mode totals.

### 5 — Typed measurement tracker

Define distinct types such as `Distance :: distinct f64`, `Duration :: distinct f64`, and `Temperature :: distinct f64`.

Store each kind in its own bounded collection. Do not use one untyped `f64` array.

**Tests:** negative duration rejection, valid negative temperature, capacity, show empty kind, reset, compile-time separation demonstrated in comments or a deliberately non-compiling snippet.

**Verify:** all stored values satisfy kind-specific ranges.

### 6 — Statistics console

`summary(values)` returns `(minimum, maximum, sum, average, ok)`. Accumulate in a wider integer type and detect overflow before narrowing.

**Tests:** empty input, one value, negatives, duplicate extrema, malformed token, sum overflow.

**Verify:** tracked count equals stored count and recomputed sum equals recorded sum.

### 7 — Number guessing game

State contains secret, minimum, maximum, attempts, hints and guessed values. `demo` always uses a fixed secret.

Reject out-of-range guesses without incrementing valid attempts. Repeated guesses return a distinct error.

**Tests:** lower and upper bounds, duplicate guess, hint before guess, win state, guess after completion.

**Verify:** secret is in range and every remembered guess is unique and in range.

### 8 — Multi-package calculator

Recommended packages:

```text
work/chapter-08/
  app/main.odin
  arithmetic/arithmetic.odin
```

`arithmetic` exposes typed operations and explicit division-by-zero failure. It does not print or parse strings.

**Tests:** each operation, zero division, unknown operation in app layer, package call counters, integer boundary.

**Verify:** total arithmetic calls equals sum of operation counters.

### 9 — Scoreboard editor

Start with `[16]Score_Entry`, then migrate to `[dynamic]Score_Entry`. Keep a monotonically increasing `reallocations` counter by observing capacity changes.

Use stable removal for user-visible ordering. Reject duplicate names unless the command explicitly updates.

**Tests:** full fixed capacity, duplicate, invalid index, empty average, growth invalidation demonstrated without dereferencing stale slices.

**Verify:** names are unique and cached total equals recomputed total.

### 10 — Word-frequency explorer

Tokenize by rune-aware whitespace and punctuation boundaries. Normalize case with Unicode-aware helpers where available; document fallback behavior.

Store owned normalized keys, not slices into temporary input.

**Tests:** empty input, accents, emoji, repeated spaces, punctuation, deterministic top ordering on equal counts.

**Verify:** sum of frequencies equals token count.

### 11 — Inventory terminal

Model item kind with an enum and payload with a tagged union. A consumed item remains addressable but has `consumed = true`.

**Tests:** unknown kind, duplicate name, use consumed item, capacity, key behavior, potion quantity.

**Verify:** union tag matches item kind and consumed items cannot report active effects.

### 12 — In-place transform editor

`Transform` is mutated through `^Transform`; inspection accepts `^const Transform`. Optional pointer paths must check nil before access.

**Tests:** move, scale, reset, repeated mutation, nil optional path, zero scale policy.

**Verify:** scale remains finite and above the chosen minimum.

### 13 — Safe file copier

Separate `copy_file(fs, source, destination)` from CLI parsing. Inject a filesystem adapter for tests.

Open source first, then destination, and attach cleanup immediately with `defer`. Refuse overwrite unless explicitly supported.

**Tests:** missing source, existing destination, partial write, close failure reporting, empty file, binary bytes.

**Verify:** successful destination size and checksum match source.

---

## Part II — Memory and Systems Programming

### 14 — Lifetime visualizer

Represent allocations with a generation, state (`Live`, `Borrowed`, `Released`) and borrow count. External references use handles, not raw pointers.

**Tests:** double release, borrow after release, release while borrowed, stale generation, capacity, reset.

**Verify:** released slots have zero borrows and live count matches records.

### 15 — Allocator-aware text builder

Wrap the selected allocator with counters. The builder owns its buffer and releases it in `destroy`.

Do not switch allocator while live allocations from the previous allocator remain unless the builder is reset first.

**Tests:** forced allocation failure, empty append, growth, switch policy, balanced frees, reset.

**Verify:** live bytes equal allocated minus freed bytes.

### 16 — Frame scratch simulator

Use one arena reset at `end-frame` and one fixed-block pool for persistent frame objects. Reject allocation outside an active frame.

**Tests:** overflow, double begin, end without begin, pool exhaustion, reset reuse, escaped handle detection.

**Verify:** scratch usage is zero outside a frame and pool free + used equals capacity.

### 17 — Directory inspector

Normalize the root path, enumerate entries, collect owned metadata and sort before printing. Continue after recoverable per-entry errors and report them.

**Tests:** missing root, empty directory, extension normalization, deterministic order, permission failure through fake OS adapter, symlink policy.

**Verify:** byte total equals sum of successful file records.

### 18 — Versioned save-file tool

Use explicit encoding:

```text
magic[4] | version:u16 | payload_len:u32 | payload | checksum:u32
```

Never dump struct memory. Decode with bounds checks before every read.

**Tests:** wrong magic, truncated header, oversized payload, unsupported version, checksum mismatch, round trip.

**Verify:** encode-decode-encode yields identical bytes for the same version.

### 19 — Diagnostic command runner

Expected input errors return values; impossible internal states assert. Logging accepts a level enum and structured message fields.

**Tests:** invalid level, filtered level, bounded buffer overflow policy, expected failure path, invariant demo isolated from normal tests.

**Verify:** level totals equal emitted event count.

---

## Part III — Professional Odin

### 20 — Test-driven ledger

State contains balance and an append-only bounded transaction log. Reject non-positive amounts and overdrafts.

Write tests before implementation for deposit, withdrawal, replay and rollback-on-error.

**Verify:** replaying transactions from zero reproduces balance exactly.

### 21 — Hotspot detective

Measure named regions with a monotonic clock. Separate warm-up from measured iterations and consume a checksum to prevent dead-code elimination.

**Tests:** zero iterations, invalid size, deterministic checksum, timer adapter, counter overflow policy.

**Verify:** total measured operations match size × iterations.

### 22 — Wrapped C utility boundary

Only the wrapper package imports the foreign symbol. Convert C strings at the boundary and copy any data whose lifetime is foreign-controlled.

**Tests:** empty string, null result, forced error code, embedded zero policy, repeated calls, cleanup.

**Verify:** every successful foreign allocation has a matching release.

### 23 — Foreign image metadata reader

Expose `inspect_image(path) -> (Image_Info, Image_Error)`. Keep decoder handles and error codes private.

**Tests:** missing file, malformed fixture, valid tiny fixture, unsupported format, null metadata, repeated open/close.

**Verify:** positive dimensions and consistent channel count for successful records.

### 24 — Parallel counter lab

Provide an unsafe demonstration behind an explicit command, but keep tests on the synchronized implementation. Use a bounded queue, worker lifecycle and join on shutdown.

**Tests:** zero workers, queue full, more jobs than capacity, orderly shutdown, double shutdown, exact completed count.

**Verify:** submitted = completed + rejected + pending.

### 25 — Vector math benchmark

Implement scalar and SIMD kernels over the same input and compare outputs within a tolerance. Handle the tail scalarly.

**Tests:** lengths 0, 1, SIMD width - 1, width, width + 1, non-finite input policy.

**Verify:** scalar and SIMD checksums agree within tolerance.

### 26 — Struct inspector

Use reflection to enumerate fields and a controlled formatter for supported kinds. Unsupported kinds return an explicit marker rather than panic.

**Tests:** empty struct, nested struct, enum, slice policy, unsupported procedure field, stable field order.

**Verify:** reported field count equals reflected field count.

### 27 — Bounded queue library

Use caller-owned `[N]T` storage with head, tail and count. Distinguish `Empty` and `Full` results.

**Tests:** pop empty, push full, wrap-around, alternating operations, reset, capacity one.

**Verify:** head/tail are in bounds and count never exceeds capacity.

---

## Part IV — Data-Oriented Design

### 28 — CSV transformation pipeline

Split stages into read, tokenize, validate, transform and aggregate. Each stage produces explicit diagnostics and stage counts.

**Tests:** missing column, quoted delimiter, malformed row, empty file, duplicate header, partial success policy.

**Verify:** accepted + rejected rows equals parsed data rows.

### 29 — Particle layout experiment

Implement equivalent AoS and SoA datasets. Initialize from the same deterministic seed and update with identical arithmetic.

**Tests:** zero particles, one particle, tail sizes, checksum mismatch detector, iteration zero, capacity limit.

**Verify:** both layouts produce the same logical state checksum.

### 30 — Resource handle console

Handle = index + generation. Destroy increments generation and returns the slot to a free list. Lookup validates bounds, alive state and generation.

**Tests:** destroy twice, stale lookup, reuse, full pool, invalid index, generation policy.

**Verify:** free + live equals capacity and no free slot is marked alive.

### 31 — Tiny ECS sandbox

Use generation entity IDs, sparse-to-dense component sets and swap-remove. Systems iterate the smallest relevant dense set and validate companion components.

**Tests:** stale entity, duplicate component, missing component, removal swap, destroy cleanup, deterministic step.

**Verify:** sparse/dense mappings are reciprocal for every component set.

### 32 — Frame scheduler

Represent phases as an enum and jobs with explicit dependencies. Topologically sort within a phase or reject cycles before execution.

**Tests:** cycle, missing dependency, phase full, deterministic tie order, failed job policy, shutdown.

**Verify:** every executed dependency appears earlier in the frame trace.

### 33 — Asset registry shell

Asset records contain handle generation, normalized key, state, reference count and artifact metadata. Loading is stateful: `Unloaded → Loading → Ready|Failed`.

**Tests:** retain/release, release at zero, stale handle, failed reload, duplicate normalized path, capacity.

**Verify:** ready assets have valid artifacts and zero-reference policy is respected.

---

## Part V — Graphics and Game Technology

### 34 — Input state visualizer

Keep `previous`, `current`, `pressed` and `released` bitsets. At frame start, derive transitions then clear one-frame events.

**Tests:** repeated down, up without down, down-up same frame policy, reset, multiple keys, frame advance.

**Verify:** a key cannot be both held false and pressed true after transition resolution.

### 35 — ASCII/software canvas

Framebuffer is caller-owned. Drawing procedures clip before indexing and count only touched in-bounds pixels.

**Tests:** point edges, negative coordinates, rectangle clipping, zero dimensions, full clear, deterministic checksum.

**Verify:** draw-call count and touched-pixel count match the command trace.

### 36 — Material catalog

Use handles for textures, meshes and materials. Material creation validates referenced resources and substitutes a documented fallback when allowed.

**Tests:** missing texture, stale texture handle, duplicate names, invalid dimensions, fallback, release dependency policy.

**Verify:** every live material references live compatible resources.

### 37 — Scene graph explorer

Store parent handles and local transforms. Compute world transforms by walking or ordered propagation. Reject cycles before committing a parent change.

**Tests:** self-parent, indirect cycle, reparent, destroy parent policy, deep chain, dirty propagation.

**Verify:** every parent is valid and graph traversal visits each live node once.

### 38 — Event-driven mixer

Commands enqueue play, stop and volume changes; the audio step consumes them and mutates voices. Clamp volume and define voice-stealing policy.

**Tests:** missing clip, invalid voice, volume bounds, queue full, stop twice, deterministic offline mix checksum.

**Verify:** active voice count matches voice states.

### 39 — Immediate-mode editor UI

UI emits editor commands; it does not mutate world state directly. History stores reversible before/after data and truncates redo after a new edit.

**Tests:** undo, redo, edit after undo, selection stale handle, history capacity, multi-step transaction.

**Verify:** history cursor is between zero and count and selected entities are live.

### 40 — Reloadable module host

Expose a versioned procedure table and host-owned persistent state. Validate ABI version and required symbols before swapping modules.

**Tests:** missing symbol, wrong version, failed candidate keeps old module, state migration, reload twice, shutdown.

**Verify:** active module table is complete and persistent state version is supported.

---

## Part VI — Capstone Engine

### 41 — Architecture constraint explorer

Represent subsystem dependencies as data. `check-dependency` rejects upward or cyclic dependencies and prints a path explaining the violation.

**Tests:** direct cycle, indirect cycle, legal edge, duplicate subsystem, unknown node, deterministic graph output.

**Verify:** dependency graph remains acyclic.

### 42 — Platform event loop

Define a platform interface for time, events, files and window state. The headless implementation drives deterministic tests.

**Tests:** quit event, resize, focus change, monotonic time, event capacity, clean shutdown.

**Verify:** event queue indices and platform lifecycle state are consistent.

### 43 — Renderer command inspector

Gameplay emits renderer commands into a bounded buffer. Sort by explicit key and execute through a backend interface.

**Tests:** command overflow, stable sort ties, invalid resource, empty frame, clipping, backend failure.

**Verify:** submitted = executed + rejected and command resources are valid.

### 44 — Asset compiler

Build a source → import → validate → compile → artifact pipeline. Artifact names derive from content and settings, not timestamps.

**Tests:** missing source, malformed source, unchanged rebuild, dependency change, corrupt artifact, deterministic hash.

**Verify:** manifest hashes match artifact bytes and dependencies exist.

### 45 — Runtime world inspector

Integrate entity lifecycle, component stores, hierarchy and fixed-step systems. Keep persistent IDs separate from runtime handles.

**Tests:** spawn/destroy, stale handle, component cleanup, hierarchy cycle, fixed-step replay, capacity.

**Verify:** all world and component invariants pass after every command in debug tests.

### 46 — Editor history console

Commands are the unit of mutation. Store enough data for exact undo/redo and mark scenes dirty only on successful changes.

**Tests:** position edit, rename, create/destroy undo, redo truncation, stale target, save dirty state.

**Verify:** replaying history from a snapshot reaches the same scene checksum.

### 47 — Frame budget profiler

Track timings per frame phase in a ring buffer and compare against configured budgets. Report percentile or worst-frame observations, not only averages.

**Tests:** zero samples, ring wrap, over-budget phase, timer injection, nested scope policy, reset.

**Verify:** phase totals are non-negative and sample counts do not exceed capacity.

### 48 — Release packager

Build from a manifest into a clean staging directory, copy only declared artifacts, generate checksums and write a deterministic release manifest.

**Tests:** missing artifact, duplicate destination, stale staging file, checksum mismatch, repeated build equality, platform variant.

**Verify:** every staged file is declared and every declared checksum matches bytes on disk.

---

## Reference completion checklist

For each chapter, the solution is complete when:

- the application remains runnable after every level;
- command parsing is separate from domain logic;
- at least six boundary tests pass;
- `demo` is deterministic;
- `stats` derives from actual state rather than hard-coded output;
- `verify` recomputes invariants;
- corrupt save data is rejected without assertion or panic;
- replaying the same transcript produces the same final checksum;
- ownership and invalidation rules are documented in the chapter project's README.

These are reference solutions, not copy-paste substitutes for learning. Different code is correct when it preserves the same observable behavior, ownership rules, failure handling, and invariants.