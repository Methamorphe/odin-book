# Interactive Exercise Workbook

This workbook is now the primary exercise path for all 48 chapters. It contains **240 cumulative, runnable exercises**: five levels for every chapter.

## The five levels used in every chapter

Work in `work/chapter-NN/` and keep the project runnable after each level.

### Level 1 — Guided build · Foundation

Implement the project card's first command and observable result. Print help at startup, reject empty input with `error: input required`, and keep parsing outside `main`.

### Level 2 — Interactive shell · Applied

Implement the second command plus `help`, `demo`, `reset`, `stats`, and `quit`. Commands are case-insensitive and whitespace-tolerant. Unknown commands print `error: unknown command '<name>'`. `demo` is deterministic and includes one valid interaction, one state change, and one rejected command.

### Level 3 — Test-first boundaries · Applied

Move logic behind procedures that can be tested without standard input. Add at least six `@(test)` cases: happy path, empty input, malformed input, minimum value, capacity/boundary, and a two-operation sequence. User-controlled input must never trigger an assertion or panic.

### Level 4 — Instrument and explain · Systems

Make `stats` report accepted and rejected commands, current and peak state counts, completed operations, and the chapter metric listed below. Run the demo normally and under deliberately constrained capacity. Record measured observations in `OBSERVATIONS.md`.

### Level 5 — Persistent product · Challenge

Add `save <path>`, `load <path>`, `replay <path>`, and `verify`. Replaying the same transcript must produce the same final state. Corrupt data returns an explicit error. Add one test that intentionally breaks an invariant and proves `verify` detects it.

## Universal definition of done

```bash
odin run work/chapter-NN
odin test work/chapter-NN
printf 'demo\nstats\nverify\nquit\n' | odin run work/chapter-NN
```

A chapter is complete only when another learner can reproduce the session from its README without editing the source.

## Part I — Foundations

<a id="chapter-1"></a>
### 1 — Why Odin?

Build a **project evaluator**. Implement `evaluate <name> <latency-ms> <memory-mb> <ffi yes|no>` and `compare <name-a> <name-b>`. Produce a ranked recommendation with explicit constraints, not a generic opinion. `stats` reports evaluations by recommendation class. Test zero budgets and contradictory requirements.

<a id="chapter-2"></a>
### 2 — Installing Odin

Build a **toolchain doctor**. Implement `check` and `explain <check-name>`. Produce PASS/FAIL rows for compiler path, version, formatter and environment. `stats` reports passed and failed checks. Test a missing compiler and a deliberately wrong expected version.

<a id="chapter-3"></a>
### 3 — Your first Odin program

Build an **interactive greeter**. Implement `greet <name>` and `style plain|loud`. Print a personalized result and continue prompting until `quit`. `stats` reports greetings per style. Test blank names, non-ASCII names and repeated greetings.

<a id="chapter-4"></a>
### 4 — Values, variables and constants

Build a **unit converter**. Implement `convert <value> <mode>` and `precision <0..6>`. Support at least Celsius/Fahrenheit and kilometres/miles. `stats` reports conversions per mode. Test negative values, invalid modes and precision boundaries.

<a id="chapter-5"></a>
### 5 — Primitive and named types

Build a **typed measurement tracker**. Implement `record <distance|duration|temperature> <value>` and `show <kind>`. Use distinct named types and prevent accidental cross-type operations. `stats` reports values per type. Test range validation and compile-time type separation.

<a id="chapter-6"></a>
### 6 — Procedures and multiple return values

Build a **statistics console**. Implement `add <integer...>` and `summary`. Return minimum, maximum, sum, average and status through procedures and multiple return values. `stats` reports numbers processed. Test empty input, one value and overflow-sized input.

<a id="chapter-7"></a>
### 7 — Control flow

Build a deterministic **number guessing game**. Implement `guess <number>` and `hint`. `demo` uses a fixed secret; normal mode may accept a seed. `stats` reports guesses and hints. Test repeated guesses and values outside the accepted range.

<a id="chapter-8"></a>
### 8 — Packages and project organization

Build a **multi-package calculator**. Implement `calc <add|sub|mul|div> <a> <b>` and `package-info`. Parsing stays in `main`; arithmetic lives in another package. `stats` reports calls per package. Test division by zero and an unknown operation.

<a id="chapter-9"></a>
### 9 — Arrays, slices and dynamic arrays

Build a **scoreboard editor**. Implement `add <name> <score>` and `remove <index>`, plus `list` and `average`. Use a fixed array first, then a dynamic array. `stats` reports length, capacity and reallocations. Test duplicate names, full capacity and slice invalidation after growth.

<a id="chapter-10"></a>
### 10 — Maps, strings and runes

Build a **word-frequency explorer**. Implement `analyze <text>` and `top <count>`. Normalize case while preserving valid UTF-8. `stats` reports unique words and runes. Test empty text, accents, emoji and repeated whitespace.

<a id="chapter-11"></a>
### 11 — Structs, enums and unions

Build an **inventory terminal**. Implement `create <name> <weapon|potion|key>` and `use <name>`. Model behavior with structs, enums and a tagged union. `stats` reports items by kind. Test unknown kinds and attempts to use a consumed item.

<a id="chapter-12"></a>
### 12 — Pointers and addressability

Build an **in-place transform editor**. Implement `move <x> <y>` and `scale <factor>`. Mutate a shared transform through pointers and expose a read-only inspection procedure. `stats` reports pointer mutations. Test nil handling in an explicit optional path and repeated reset.

<a id="chapter-13"></a>
### 13 — `defer`, cleanup and explicit errors

Build a **safe file copier**. Implement `copy <source> <destination>` and `status`. Every opened resource must close on all paths. Return explicit errors for missing source and existing destination. `stats` reports bytes copied and cleanup calls.

## Part II — Memory and Systems Programming

<a id="chapter-14"></a>
### 14 — The Odin memory model

Build a **lifetime visualizer**. Implement `allocate <label>`, `borrow <label>` and `release <label>`. Print a trace showing valid, borrowed and released values. `stats` reports live lifetimes. Test double release and borrow-after-release detection.

<a id="chapter-15"></a>
### 15 — Allocators and `context.allocator`

Build an **allocator-aware text builder**. Implement `append <text>` and `allocator system|tracking`. Route allocations through the selected allocator. `stats` reports allocations, frees and bytes. Test allocator failure and empty fragments.

<a id="chapter-16"></a>
### 16 — Arenas, pools and temporary memory

Build a **frame scratch simulator**. Implement `begin-frame`, `alloc <bytes>` and `end-frame`. Reset temporary memory between frames and reuse fixed-block slots. `stats` reports peak frame bytes, pool occupancy and resets. Test overflow and allocation outside a frame.

<a id="chapter-17"></a>
### 17 — Files, paths and OS services

Build a **directory inspector**. Implement `list <path>` and `filter <extension>`. Print sorted metadata and byte totals. `stats` reports visited files and failures. Test missing paths, empty directories and permission errors where the platform permits.

<a id="chapter-18"></a>
### 18 — Serialization and binary layouts

Build a versioned **save-file tool**. Implement `set <field> <value>` and `write <path>`, then read the file back. Include magic bytes, version and payload length. `stats` reports serialized bytes. Test truncated files and unsupported versions.

<a id="chapter-19"></a>
### 19 — Assertions, diagnostics and logging

Build a **diagnostic command runner**. Implement `log <debug|info|warn|error> <message>` and `assert-demo`. Expected failures return errors; programmer invariants use assertions. `stats` reports events per level. Test invalid levels and distinguish runtime failure from invariant violation.

## Part III — Professional Odin

<a id="chapter-20"></a>
### 20 — Testing and reproducible builds

Build a test-driven **ledger**. Implement `deposit <amount>` and `withdraw <amount>`. Start with failing tests, then implement. `stats` reports transactions and rejected withdrawals. Test negative amounts, insufficient funds and a deterministic replay fixture.

<a id="chapter-21"></a>
### 21 — Debugging and profiling

Build a **hotspot detective**. Implement `run <size> <iterations>` and `profile`. Add timers and operation counters before optimizing. `stats` reports time per measured region. Test zero iterations and show warm-up versus measured runs in `OBSERVATIONS.md`.

<a id="chapter-22"></a>
### 22 — C interoperability

Build a **wrapped C utility boundary**. Implement `call <text>` and `boundary-stats`. All foreign details stay in one wrapper. Translate null pointers and error codes into Odin results. Test empty strings and a forced foreign failure.

<a id="chapter-23"></a>
### 23 — Foreign libraries and bindings

Build a **foreign image metadata reader**. Implement `inspect <path>` and `library-error-demo`. Return dimensions through an Odin-owned API and translate library errors. `stats` reports calls and failures. Test malformed fixtures and missing files.

<a id="chapter-24"></a>
### 24 — Threads, atomics and synchronization

Build a **parallel counter lab**. Implement `workers <count>` and `run <jobs>`. Provide a deliberately unsafe mode and a correct synchronized mode. `stats` reports completed jobs per worker. Test zero workers, queue saturation and race-free shutdown.

<a id="chapter-25"></a>
### 25 — SIMD and numerical code

Build a **vector math benchmark**. Implement `size <count>` and `bench <iterations>`. Compare scalar and SIMD paths using identical input and checksum. `stats` reports durations and elements processed. Test lengths not divisible by SIMD width.

<a id="chapter-26"></a>
### 26 — Reflection and compile-time features

Build a **struct inspector**. Implement `inspect <type-name>` and `fields <type-name>`. Print field names, types and selected values using reflection. `stats` reports inspected fields by type. Test empty structs and unsupported field kinds.

<a id="chapter-27"></a>
### 27 — API design in Odin

Build a bounded **queue library and shell**. Implement `push <value>` and `pop`. The API exposes capacity, empty/full errors and caller-owned storage. `stats` reports occupancy and rejected pushes. Test pop-empty, push-full and wrap-around.

## Part IV — Data-Oriented Design

<a id="chapter-28"></a>
### 28 — Thinking in data transformations

Build a **CSV transformation pipeline**. Implement `load <path>` and `filter <column> <value>`. Separate read, parse, validate, transform and aggregate stages. `stats` reports rows at each stage. Test missing columns and malformed rows.

<a id="chapter-29"></a>
### 29 — Cache-aware layouts

Build a **particle layout experiment**. Implement `layout aos|soa` and `bench <count> <iterations>`. Both layouts must produce the same checksum. `stats` reports bytes touched and timing. Test zero particles and mismatched result detection.

<a id="chapter-30"></a>
### 30 — Handles, generations and object pools

Build a **resource handle console**. Implement `create <name>` and `destroy <index> <generation>`, plus `get`. Reuse slots with incremented generations. `stats` reports live slots and stale lookups. Test destroy-twice and stale handles after reuse.

<a id="chapter-31"></a>
### 31 — Entity-component systems

Build a **tiny ECS sandbox**. Implement `spawn <name>` and `add <entity> <component>`, plus `remove`, `step` and `inspect`. Systems process matching component sets only. `stats` reports entities and query matches. Test stale entities and missing components.

<a id="chapter-32"></a>
### 32 — Job systems and frame pipelines

Build a **frame scheduler**. Implement `enqueue <phase> <job>` and `frame`. Use explicit phases and dependencies. `stats` reports jobs per phase and stalls. Test a dependency cycle, phase capacity and deterministic ordering.

<a id="chapter-33"></a>
### 33 — Asset registries and resource lifetime

Build an **asset registry shell**. Implement `load <path>` and `release <handle>`, plus `retain` and `reload`. `stats` reports loads, references and reloads. Test release-at-zero, stale handles and reload of a missing asset.

## Part V — Graphics and Game Technology

<a id="chapter-34"></a>
### 34 — Window creation and input

Build an **input state visualizer**. Implement `event <key> down|up` and `frame`. Print pressed, held and released transitions once per frame. `stats` reports transition counts. Test repeated key-down and key-up without key-down.

<a id="chapter-35"></a>
### 35 — Rendering fundamentals

Build an **ASCII/software canvas**. Implement `point <x> <y>` and `rect <x> <y> <w> <h>`. Maintain a deterministic framebuffer checksum. `stats` reports draw calls and pixels touched. Test clipping and zero-size geometry.

<a id="chapter-36"></a>
### 36 — Textures, meshes and materials

Build a **material catalog**. Implement `texture <name> <w> <h>` and `material <name> <texture>`, plus mesh creation. Validate resource links and provide a fallback. `stats` reports resources and substitutions. Test missing textures and incompatible material data.

<a id="chapter-37"></a>
### 37 — Cameras, transforms and scenes

Build a **scene graph explorer**. Implement `node <name>` and `parent <child> <parent>`, plus local/world movement. `stats` reports visited nodes and recomputations. Test parent cycles and destruction of a parent.

<a id="chapter-38"></a>
### 38 — Audio and event systems

Build an **event-driven mixer**. Implement `play <clip>` and `volume <voice> <0..1>`, plus stop and event emission. `stats` reports active voices and dispatched events. Test a missing voice and out-of-range volume.

<a id="chapter-39"></a>
### 39 — Immediate-mode tools and editor UI

Build a terminal **property editor**. Implement `select <entity>` and `set <field> <value>`, plus undo/redo. Redraw the view from current state each loop. `stats` reports edits and history depth. Test editing without selection and redo after a new edit.

<a id="chapter-40"></a>
### 40 — Hot reload and plugin boundaries

Build a **reloadable rules module**. Implement `tick` and `reload <version>`. Preserve compatible state and reject incompatible ABI/state versions. `stats` reports reloads and migrations. Test failed migration and rollback to the previous module.

## Part VI — Capstone Engine

<a id="chapter-41"></a>
### 41 — Architecture and constraints

Build an **engine architecture simulator**. Implement `request <feature>` and `target desktop|server|mobile`. Produce a subsystem plan tied to explicit constraints. `stats` reports accepted and rejected constraints. Test conflicting requirements and unsupported targets.

<a id="chapter-42"></a>
### 42 — Platform layer

Build a deterministic **headless platform harness**. Implement `time <seconds>` and `inject-key <key> down|up`, plus virtual file operations. `stats` reports platform calls by category. Test time moving backward and missing files.

<a id="chapter-43"></a>
### 43 — Renderer

Build a **render command pipeline**. Implement `submit <layer> <material> <entity>` and `flush`. Sort stably and execute through a backend boundary. `stats` reports submitted, sorted and flushed commands. Test buffer-full and equal sort keys.

<a id="chapter-44"></a>
### 44 — Asset pipeline

Build an **asset compiler CLI**. Implement `build <source>` and `rebuild-changed`. Emit content hashes and dependency records. `stats` reports cache hits, misses and rebuilt assets. Test missing dependencies and unchanged rebuilds.

<a id="chapter-45"></a>
### 45 — Runtime world

Build a **runtime scene sandbox**. Implement `spawn <name>` and `step <dt>`, plus destroy and query. Use stable entity handles and deterministic fixed steps. `stats` reports spawned, destroyed and updated entities. Test stale handles and fixed-step overflow.

<a id="chapter-46"></a>
### 46 — Editor

Build a **scene editor session**. Implement `create <name>` and `undo`, plus edit, redo and save. All mutations are commands. `stats` reports command count, history depth and dirty state. Test undo-empty, branching history and corrupt scenes.

<a id="chapter-47"></a>
### 47 — Profiling and optimization

Build a **budget dashboard**. Implement `sample <system> <milliseconds>` and `report`. Calculate p50, p95 and budget violations. `stats` reports hotspots by accumulated time. Test no samples, one sample and one extreme outlier.

<a id="chapter-48"></a>
### 48 — Packaging a small game

Build a **release packager**. Implement `target <name>` and `package <output-dir>`. Produce a reproducible manifest and validation report. `stats` reports files and manifest hash. Test missing data and ensure timestamps do not alter the package hash.

## Review rubric

Score each level from 0 to 2:

- **0:** absent or cannot be reproduced;
- **1:** happy path works but boundaries, tests or ownership are unclear;
- **2:** acceptance checks pass and behavior is documented.

A chapter scores 10/10 only when all five levels are reproducible. Do not advance merely because the program compiled.
