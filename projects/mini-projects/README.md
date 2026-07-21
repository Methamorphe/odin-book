# Twenty Odin Mini-Projects

These projects bridge isolated chapter examples and the Threadline Engine. Each project should remain independently buildable, testable, and small enough to finish in several focused sessions.

## Progression

| # | Project | Core chapters | Main artifact |
|---:|---|---|---|
| 01 | CLI task tracker | 3–13 | durable command-line application |
| 02 | Arena allocator | 14–16 | allocator with reset and diagnostics |
| 03 | Fixed block pool | 12, 15–16, 30 | validated reusable object storage |
| 04 | JSON parser | 6–13, 18 | tokenizer, AST, diagnostics |
| 05 | Hash map | 9–10, 15, 27, 29 | open-addressing generic-style map |
| 06 | Binary archive | 17–18 | versioned writer/reader |
| 07 | Structured logger | 13, 19 | bounded sinks and fields |
| 08 | Test runner | 20 | discovery, filtering, reporting |
| 09 | CPU profiler | 21, 47 | nested timing scopes |
| 10 | C library wrapper | 22–23 | safe foreign boundary |
| 11 | Thread pool | 24, 32 | bounded jobs and shutdown |
| 12 | SIMD image filter | 25 | scalar/SIMD kernels |
| 13 | Reflection serializer | 26 | schema inspection and validation |
| 14 | Generational resource pool | 30, 33 | stable handles and states |
| 15 | Minimal ECS | 28–31 | dense components and queries |
| 16 | Asset compiler | 17–18, 33, 44 | deterministic artifacts and manifest |
| 17 | Input recorder | 34 | action mapping and replay |
| 18 | Software renderer | 35–37, 43 | command extraction and PPM output |
| 19 | Immediate-mode editor | 39, 46 | stable IDs and undo/redo |
| 20 | Hot-reload host | 23, 40 | versioned plugin simulation |

## Shared completion rules

Every mini-project must provide:

- a `main.odin` demonstration;
- unit or invariant tests where practical;
- explicit ownership and cleanup notes;
- malformed-input and capacity-boundary behavior;
- a short architecture section;
- deterministic output in CI mode;
- no performance claim without a benchmark.

## Recommended order

Complete 01–07 after Part II, 08–13 after Part III, 14–16 after Part IV, and 17–20 during Parts V and VI.

Each directory contains a project brief and starter implementation. Treat starters as intentionally compact foundations: extend them until every acceptance criterion is met.