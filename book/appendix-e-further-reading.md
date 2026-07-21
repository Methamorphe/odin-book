# Appendix E — Further Reading

[← Appendix D: Exercise Index](appendix-d-exercise-index.md)

This appendix collects resources that deepen the subjects covered by the book. Prefer primary documentation, source code, specifications, and measured engineering reports over isolated snippets.

## E.1 Odin language and ecosystem

- [Odin documentation](https://odin-lang.org/docs/overview/) — language overview and core concepts.
- [Odin package documentation](https://pkg.odin-lang.org/) — searchable standard and vendor package reference.
- [Odin source repository](https://github.com/odin-lang/Odin) — compiler, core library, tests, examples, and release history.
- [Odin news and articles](https://odin-lang.org/news/) — design notes, release information, and interoperability articles.

When an API detail matters, read the exact source revision pinned by the project’s CI.

## E.2 Systems programming

- *Computer Systems: A Programmer’s Perspective* by Bryant and O’Hallaron — machine representation, linking, memory, and performance.
- *The Linux Programming Interface* by Michael Kerrisk — processes, files, signals, threads, and Linux APIs.
- *Operating Systems: Three Easy Pieces* by Arpaci-Dusseau and Arpaci-Dusseau — free online treatment of virtualization, concurrency, and persistence.
- [POSIX specifications](https://pubs.opengroup.org/onlinepubs/9699919799/) — authoritative Unix interface contracts.
- [Microsoft Win32 documentation](https://learn.microsoft.com/windows/win32/) — Windows platform APIs.

## E.3 Memory allocation and lifetime

- *Dynamic Storage Allocation: A Survey and Critical Review* by Wilson et al. — allocator strategies and fragmentation.
- Doug Lea’s allocator notes — practical general-purpose allocator design.
- [mimalloc technical documentation](https://github.com/microsoft/mimalloc) — modern allocator organization and measurement.
- [rpmalloc](https://github.com/mjansson/rpmalloc) — thread-aware allocator implementation.

Study allocator designs to understand trade-offs, not to copy complexity into every project.

## E.4 Data-oriented design

- *Data-Oriented Design* by Richard Fabian — practical introduction to organizing software around data transformation.
- Mike Acton’s talks on data-oriented design — reasoning from hardware behavior and actual workloads.
- *Game Programming Patterns* by Robert Nystrom — approachable patterns, including data locality and event queues.
- [Our Machinery articles](https://ruby0x1.github.io/machinery_blog_archive/) — engine architecture, IDs, data models, and tools.

## E.5 Computer architecture and performance

- *Computer Architecture: A Quantitative Approach* by Hennessy and Patterson.
- Agner Fog’s optimization manuals — instruction costs, calling conventions, and CPU microarchitecture.
- [Intel optimization manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).
- [AMD optimization guides](https://www.amd.com/en/developer.html).
- [LLVM documentation](https://llvm.org/docs/) — compiler optimization and code generation.

Use hardware manuals after profiling identifies a real bottleneck.

## E.6 Profiling and observability

- Brendan Gregg’s *Systems Performance* and performance diagrams.
- [Tracy Profiler](https://github.com/wolfpld/tracy) — real-time CPU/GPU profiling.
- [Perfetto](https://perfetto.dev/) — tracing infrastructure and UI.
- [Linux perf documentation](https://perf.wiki.kernel.org/).
- platform profilers such as Instruments, Windows Performance Analyzer, RenderDoc, and vendor GPU tools.

A useful profiling practice records workload, build identity, machine, sample count, and before/after evidence.

## E.7 Concurrency

- *The Art of Multiprocessor Programming* by Herlihy and Shavit.
- *C++ Concurrency in Action* by Anthony Williams — language-specific examples but broadly useful models.
- *Is Parallel Programming Hard, And, If So, What Can You Do About It?* by Paul McKenney.
- [1024cores](https://www.1024cores.net/) — lock-free algorithms and memory-model discussion.

Start with ownership partitioning, bounded queues, and simple locks. Reach for lock-free structures only with measured need and a test strategy.

## E.8 Networking and distributed systems

- *UNIX Network Programming* by W. Richard Stevens.
- *TCP/IP Illustrated* by Stevens.
- *Designing Data-Intensive Applications* by Martin Kleppmann.
- protocol specifications relevant to the system being built.

Network parsers should be bounded, stateful, timeout-aware, and treated as hostile-input boundaries.

## E.9 File formats and serialization

- Kaitai Struct documentation for declarative binary formats.
- FlatBuffers, Cap’n Proto, and Protocol Buffers documentation for schema-driven trade-offs.
- [Reproducible Builds](https://reproducible-builds.org/) for deterministic artifacts.
- format specifications such as PNG, WAV, glTF, and ZIP when implementing importers.

Prefer explicit versioned schemas and deterministic writers. Never depend on arbitrary in-memory struct layout as a durable format.

## E.10 C interoperability and ABI design

- [Odin binding to C](https://odin-lang.org/news/binding-to-c/).
- platform ABI documents for System V AMD64, Windows x64, and ARM64.
- library headers and upstream source for every bound dependency.
- *Linkers and Loaders* by John Levine.

Test sizes, alignments, calling conventions, ownership, and error translation at the boundary.

## E.11 Graphics

- *Real-Time Rendering* by Akenine-Möller, Haines, Hoffman, et al.
- *Physically Based Rendering* by Pharr, Jakob, and Humphreys.
- [LearnOpenGL](https://learnopengl.com/) for introductory rendering concepts.
- [Vulkan specification](https://registry.khronos.org/vulkan/).
- [Direct3D documentation](https://learn.microsoft.com/windows/win32/direct3d).
- [Metal documentation](https://developer.apple.com/metal/).
- [WebGPU specification](https://www.w3.org/TR/webgpu/).
- [RenderDoc](https://renderdoc.org/) for frame capture and debugging.

Learn one explicit graphics API deeply enough to understand resource state, synchronization, and frames in flight.

## E.12 Mathematics for games and graphics

- *3D Math Primer for Graphics and Game Development* by Dunn and Parberry.
- *Mathematics for 3D Game Programming and Computer Graphics* by Lengyel.
- *Geometric Tools for Computer Graphics* by Schneider and Eberly.
- *Foundations of Game Engine Development* by Eric Lengyel.

Always document coordinate system, handedness, matrix order, angle units, and numerical tolerance.

## E.13 Game-engine architecture

- *Game Engine Architecture* by Jason Gregory.
- *Game Programming Gems* series.
- *Engine Architecture* talks and postmortems from GDC.
- source code from engines and frameworks whose license permits study.

Read architecture material critically. A subsystem designed for a large studio, console certification, or decades of compatibility may be inappropriate for a small engine.

## E.14 Entity-component systems

- Unity DOTS and Entities documentation for archetype-based ECS concepts.
- EnTT documentation and source.
- Flecs documentation and design notes.
- Bitsquid and Our Machinery articles on IDs and engine data.

Compare sparse sets, archetypes, tables, and simple component arrays against the actual query workload.

## E.15 Audio

- *The Computer Music Tutorial* by Curtis Roads.
- platform and middleware documentation for callback constraints, mixing, streaming, and device changes.
- public talks on game-audio pipelines and voice management.

Keep the real-time audio callback free from blocking, unbounded allocation, and unsafe cross-thread ownership.

## E.16 Tools and editor design

- Dear ImGui source and documentation for immediate-mode UI concepts.
- editor architecture talks from game-engine teams.
- command-pattern and transaction literature for undo/redo.
- file-watching and build-system documentation for live iteration.

Editor actions should become explicit commands when they mutate durable project state.

## E.17 Hot reload and plugins

- POSIX `dlopen` and Windows dynamic-library documentation.
- ABI stability documentation from mature plugin systems.
- articles on live coding, code unloading, and state migration.

Keep persistent state host-owned, use versioned procedure tables, and reload only at safe synchronization points.

## E.18 Testing

- *Growing Object-Oriented Software, Guided by Tests* for feedback-loop ideas.
- property-based testing literature and tools.
- fuzzing documentation from LLVM libFuzzer, AFL++, and OSS-Fuzz.
- golden-test and snapshot-test practices for deterministic tools.

Low-level systems benefit greatly from malformed-input tests, allocation-failure tests, stale-handle tests, and serialization round trips.

## E.19 Security

- [OWASP](https://owasp.org/) guidance for input validation and common vulnerability classes.
- *The CERT C Coding Standard* for native-code risk patterns.
- platform guidance on sandboxing, code signing, and secure update delivery.

Even non-networked tools process untrusted files, paths, plugins, and project data.

## E.20 Build and release engineering

- [Semantic Versioning](https://semver.org/).
- [Reproducible Builds](https://reproducible-builds.org/).
- platform code-signing and notarization documentation.
- Software Package Data Exchange (SPDX) for license metadata.
- supply-chain guidance such as SLSA.

A release is not only an optimized executable. It includes manifests, assets, licenses, checksums, symbols, smoke tests, and reproducible instructions.

## E.21 Source-reading practice

Choose one subsystem each month and read a compact implementation:

1. identify public API and ownership;
2. map data structures;
3. trace initialization and shutdown;
4. locate allocations and synchronization;
5. find invariants and assertions;
6. run benchmarks or tests;
7. summarize the design in your own words.

Source reading becomes valuable when it produces explicit models rather than copied code.

## E.22 Continuing with Odin

After completing the book, build three projects of increasing scope:

1. a command-line tool with a durable file format;
2. a graphical tool with an asset pipeline and editor state;
3. a small packaged game or simulation with profiling evidence.

For each project, pin Odin in CI, document ownership, keep examples compiling, and publish an honest postmortem describing decisions that changed after measurement.
