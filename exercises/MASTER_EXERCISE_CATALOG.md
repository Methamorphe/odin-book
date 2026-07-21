# Master Exercise Catalog — 240 Exercises

This catalog adds five graded exercises for every chapter of *The Odin Programming Book*. Existing chapter exercise files remain the place for chapter-specific prompts and solutions; this catalog provides a complete progression and acceptance criteria.

Difficulty levels:

- **F — Foundation:** direct practice of the chapter concept.
- **A — Applied:** combine the concept with earlier material.
- **S — Systems:** make ownership, layout, failure, or platform behavior explicit.
- **D — Design:** compare alternatives and document invariants.
- **C — Challenge:** build a reusable component or measurable experiment.

For every exercise: compile with the repository Odin version, add at least one assertion or test, document ownership, and avoid hidden global mutable state.

## Part I — Foundations

### Chapter 1 — Why Odin?
1. **F:** Write a program that prints build, platform, and architecture information. Acceptance: one deterministic line per value.
2. **A:** Reimplement a small C-style data transformation in idiomatic Odin. Acceptance: no classes or exceptions.
3. **S:** List every allocation and owner in a 50-line program. Acceptance: cleanup paths are explicit.
4. **D:** Compare Odin, C++, Go, and Rust for a native tool. Acceptance: a decision table with constraints.
5. **C:** Build a command-line system-information reporter with text and JSON-like output modes.

### Chapter 2 — Installing Odin
6. **F:** Verify compiler, formatter, debugger, and package documentation access.
7. **A:** Create debug and release build commands for one package.
8. **S:** Write a script that rejects an unsupported Odin version.
9. **D:** Document a reproducible workstation setup for macOS, Linux, or Windows.
10. **C:** Create a clean-machine bootstrap script and validate it in a disposable environment.

### Chapter 3 — Your First Odin Program
11. **F:** Print a greeting, integer, float, and boolean.
12. **A:** Accept a name argument and print a personalized greeting.
13. **S:** Return non-zero exit codes for invalid invocation.
14. **D:** Separate argument parsing from application behavior.
15. **C:** Build a small multi-command CLI with help and version output.

### Chapter 4 — Values, Variables, and Constants
16. **F:** Declare mutable values, constants, and inferred values for a rectangle.
17. **A:** Compute invoice totals with named tax and discount constants.
18. **S:** Detect integer overflow before multiplying user-provided dimensions.
19. **D:** Explain which values should be compile-time constants and why.
20. **C:** Build a typed configuration calculator with validation and defaults.

### Chapter 5 — Primitive and Named Types
21. **F:** Define distinct `Meters`, `Seconds`, and `Velocity` types.
22. **A:** Convert between Celsius and Fahrenheit using named types.
23. **S:** Parse fixed-width binary fields into explicit integer types.
24. **D:** Audit a program for accidental unit mixing.
25. **C:** Build a units-safe motion calculator with checked conversions.

### Chapter 6 — Procedures and Multiple Return Values
26. **F:** Write `min_max` returning two values.
27. **A:** Write a parser returning value, consumed count, and success.
28. **S:** Design a procedure that reports partial progress on failure.
29. **D:** Compare output parameters with multiple returns for a hot path.
30. **C:** Build a reusable tokenizer API using explicit result values.

### Chapter 7 — Control Flow
31. **F:** Classify numbers with `if`, `switch`, and ranges.
32. **A:** Implement FizzBuzz without duplicated output logic.
33. **S:** Add bounded retries and explicit cancellation to a loop.
34. **D:** Replace deeply nested branches with early exits.
35. **C:** Build a deterministic finite-state machine with transition tests.

### Chapter 8 — Packages and Project Organization
36. **F:** Split arithmetic and presentation into separate packages.
37. **A:** Introduce a local collection and import two sibling packages.
38. **S:** Remove an import cycle by defining a lower-level data package.
39. **D:** Draw and justify a dependency graph for a medium project.
40. **C:** Build a three-layer CLI application with no upward dependencies.

### Chapter 9 — Arrays, Slices, and Dynamic Arrays
41. **F:** Compute sum, mean, and maximum of an array.
42. **A:** Implement stable removal from a dynamic array.
43. **S:** Document every operation that may reallocate and invalidate pointers.
44. **D:** Compare fixed arrays, slices, and dynamic arrays for three workloads.
45. **C:** Build a reusable dense set with swap-remove and index mapping.

### Chapter 10 — Maps, Strings, and Runes
46. **F:** Count word frequencies.
47. **A:** Normalize Unicode-aware identifiers before comparison.
48. **S:** Avoid retaining temporary string storage across allocator resets.
49. **D:** Compare map lookup with sorted-array binary search.
50. **C:** Build an intern table with stable numeric identifiers.

### Chapter 11 — Structs, Enums, and Unions
51. **F:** Model a shape enum and tagged union.
52. **A:** Compute area through exhaustive union handling.
53. **S:** Serialize a versioned tagged record without raw layout dumping.
54. **D:** Compare tagged unions with procedure-table polymorphism.
55. **C:** Build an expression tree evaluator and pretty-printer.

### Chapter 12 — Pointers and Addressability
56. **F:** Mutate a struct through a pointer.
57. **A:** Implement an intrusive free-list over fixed storage.
58. **S:** Identify and remove a dangling-pointer bug after array growth.
59. **D:** Define when an API should accept value, pointer, or slice.
60. **C:** Build a fixed-capacity pool with pointer-free external handles.

### Chapter 13 — `defer`, Cleanup, and Explicit Errors
61. **F:** Open, use, and close a file with `defer`.
62. **A:** Acquire three resources and unwind safely after each failure point.
63. **S:** Preserve the primary error while reporting cleanup failure.
64. **D:** Design a cleanup policy for a subsystem with partial initialization.
65. **C:** Build a transactional file writer using temporary files and atomic rename.

## Part II — Memory and Systems Programming

### Chapter 14 — The Odin Memory Model
66. **F:** Label stack, static, and allocator-backed values in a program.
67. **A:** Return owned data without returning references to local storage.
68. **S:** Audit a parser for hidden lifetime coupling.
69. **D:** Write lifetime diagrams for three API designs.
70. **C:** Build a request-scoped processing pipeline with explicit ownership transfer.

### Chapter 15 — Allocators and `context.allocator`
71. **F:** Allocate and free a dynamic array with a selected allocator.
72. **A:** Route one subsystem through a counting allocator.
73. **S:** Detect leaks by balancing allocation and free counts.
74. **D:** Decide which APIs may use `context.allocator` and which require an argument.
75. **C:** Implement a tracing allocator wrapper with size and call-site statistics.

### Chapter 16 — Arenas, Pools, and Temporary Memory
76. **F:** Use an arena for one batch operation.
77. **A:** Reset temporary memory once per simulated frame.
78. **S:** Prevent temporary pointers from escaping the arena lifetime.
79. **D:** Compare arena, pool, and general heap for a workload.
80. **C:** Build a fixed-block pool with validation, reuse, and exhaustion tests.

### Chapter 17 — Files, Paths, and OS Services
81. **F:** Read a complete text file and print its size.
82. **A:** Walk a directory and filter by extension.
83. **S:** Resolve paths without depending on the process working directory.
84. **D:** Define platform boundaries for file watching and user-data paths.
85. **C:** Build a recursive file indexer with deterministic ordering and error summaries.

### Chapter 18 — Serialization and Binary Layouts
86. **F:** Encode and decode fixed-width integers explicitly.
87. **A:** Add magic, version, length, and checksum fields to a format.
88. **S:** Reject truncated, oversized, and incompatible records.
89. **D:** Compare binary, JSON, and line-oriented formats for a tool.
90. **C:** Build a versioned save format with migration from v1 to v2.

### Chapter 19 — Assertions, Diagnostics, and Logging
91. **F:** Add assertions for internal invariants.
92. **A:** Implement log levels and structured fields.
93. **S:** Separate user errors from programmer errors.
94. **D:** Define a diagnostics policy for debug and release builds.
95. **C:** Build a bounded ring-buffer logger suitable for crash reports.

## Part III — Professional Odin

### Chapter 20 — Testing and Reproducible Builds
96. **F:** Add tests for a pure function.
97. **A:** Add table-driven boundary cases.
98. **S:** Remove time, randomness, and filesystem nondeterminism from a test.
99. **D:** Define unit, integration, and smoke-test boundaries.
100. **C:** Build a golden-file test harness with explicit update mode.

### Chapter 21 — Debugging and Profiling
101. **F:** Reproduce and fix an out-of-bounds access.
102. **A:** Add timing scopes around a frame pipeline.
103. **S:** Capture enough context to diagnose a rare state transition.
104. **D:** Write a hypothesis-first profiling plan.
105. **C:** Build a lightweight hierarchical CPU profiler and report top scopes.

### Chapter 22 — C Interoperability
106. **F:** Bind and call a simple C function.
107. **A:** Translate a C struct and enum with verified sizes.
108. **S:** Document ownership for C-allocated and Odin-allocated memory.
109. **D:** Design a narrow wrapper that hides unsafe foreign details.
110. **C:** Bind a small C library and expose an idiomatic tested Odin API.

### Chapter 23 — Foreign Libraries and Bindings
111. **F:** Load one foreign dependency behind a package.
112. **A:** Convert foreign errors into a project enum.
113. **S:** Validate ABI version and optional symbols.
114. **D:** Decide static versus dynamic linking for a release target.
115. **C:** Build a generated binding verification tool for constants and layouts.

### Chapter 24 — Threads, Atomics, and Synchronization
116. **F:** Start a worker thread and join it.
117. **A:** Protect a shared counter with a mutex.
118. **S:** Replace a data race with message passing.
119. **D:** Document lock ordering and blocking rules.
120. **C:** Build a bounded multi-producer work queue with shutdown semantics.

### Chapter 25 — SIMD and Numerical Code
121. **F:** Add two vectors with scalar code and SIMD.
122. **A:** Verify numerical equivalence within a tolerance.
123. **S:** Handle unaligned tails safely.
124. **D:** Measure whether SIMD improves the actual workload.
125. **C:** Build a SIMD batch-transform kernel with scalar fallback.

### Chapter 26 — Reflection and Compile-Time Features
126. **F:** Print field names and types for a struct.
127. **A:** Generate validation for tagged fields.
128. **S:** Reject unsupported field types at compile time.
129. **D:** Compare reflection with explicit registration.
130. **C:** Build a compile-time serializer schema report.

### Chapter 27 — API Design in Odin
131. **F:** Rewrite an ambiguous API with explicit names and results.
132. **A:** Separate storage, policy, and execution.
133. **S:** Document invalidation and thread-safety rules.
134. **D:** Review an API for ownership and failure ambiguity.
135. **C:** Design a stable public package and test it only through its public surface.

## Part IV — Data-Oriented Design

### Chapter 28 — Thinking in Data Transformations
136. **F:** Express a process as input → transform → output.
137. **A:** Separate collection, transformation, and presentation passes.
138. **S:** Remove hidden mutation from a pipeline.
139. **D:** Identify hot and cold data for one workload.
140. **C:** Build a deterministic multi-stage import pipeline with per-stage diagnostics.

### Chapter 29 — Cache-Aware Layouts
141. **F:** Convert an AoS particle loop to SoA.
142. **A:** Split hot position data from cold metadata.
143. **S:** Measure contiguous and strided traversal.
144. **D:** Predict cache behavior before benchmarking.
145. **C:** Build and benchmark three layouts for 100,000 entities.

### Chapter 30 — Handles, Generations, and Object Pools
146. **F:** Create and validate a generational handle.
147. **A:** Reuse a destroyed slot without reviving stale handles.
148. **S:** Handle generation wrap policy explicitly.
149. **D:** Compare pointers, indices, and handles.
150. **C:** Build a generic fixed-capacity resource pool with diagnostics.

### Chapter 31 — Entity-Component Systems
151. **F:** Store positions and velocities in dense arrays.
152. **A:** Implement spawn, destroy, and movement iteration.
153. **S:** Maintain sparse-to-dense mappings through swap-remove.
154. **D:** Compare archetype and sparse-set designs.
155. **C:** Build a minimal ECS with three components, queries, and invariant tests.

### Chapter 32 — Job Systems and Frame Pipelines
156. **F:** Represent frame stages as explicit procedures.
157. **A:** Build a dependency graph for independent jobs.
158. **S:** Add safe shutdown and draining.
159. **D:** Define which stages may run concurrently.
160. **C:** Build a work-stealing or centralized thread pool with deterministic test mode.

### Chapter 33 — Asset Registries and Resource Lifetime
161. **F:** Map stable asset IDs to records.
162. **A:** Add loading, ready, failed, and unloaded states.
163. **S:** Prevent use-after-unload through generations or references.
164. **D:** Separate source assets from runtime artifacts.
165. **C:** Build an asynchronous asset registry with dependency tracking.

## Part V — Graphics and Game Technology

### Chapter 34 — Window Creation and Input
166. **F:** Normalize key down, pressed, and released states.
167. **A:** Record input events and replay them.
168. **S:** Handle focus loss without stuck inputs.
169. **D:** Define a platform-independent input event schema.
170. **C:** Build an action-mapping layer with rebinding and deterministic replay.

### Chapter 35 — Rendering Fundamentals
171. **F:** Build and sort a draw-command list.
172. **A:** Separate render extraction from submission.
173. **S:** Validate resource handles before command execution.
174. **D:** Define frame-resource ownership across CPU and GPU timelines.
175. **C:** Build a software command renderer producing a PPM image.

### Chapter 36 — Textures, Meshes, and Materials
176. **F:** Define runtime records for textures, meshes, and materials.
177. **A:** Deduplicate materials by stable key.
178. **S:** Validate mesh bounds and index ranges.
179. **D:** Separate immutable resource data from per-instance state.
180. **C:** Build a mesh and texture artifact compiler with versioned headers.

### Chapter 37 — Cameras, Transforms, and Scenes
181. **F:** Compose local and parent transforms.
182. **A:** Implement camera movement and projection settings.
183. **S:** Detect cycles in a scene hierarchy.
184. **D:** Compare hierarchy traversal strategies.
185. **C:** Build a scene graph with dirty propagation and serialization.

### Chapter 38 — Audio and Event Systems
186. **F:** Queue and consume typed events.
187. **A:** Add event priorities and bounded capacity.
188. **S:** Keep the audio callback allocation- and lock-free.
189. **D:** Separate gameplay events from audio commands.
190. **C:** Build a mixer command queue and offline WAV renderer.

### Chapter 39 — Immediate-Mode Tools and Editor UI
191. **F:** Build stable widget IDs from a stack.
192. **A:** Implement button, slider, and text-field state.
193. **S:** Preserve selection across reordered data.
194. **D:** Separate editor commands from direct world mutation.
195. **C:** Build an immediate-mode hierarchy inspector with undoable edits.

### Chapter 40 — Hot Reload and Plugin Boundaries
196. **F:** Define a versioned plugin API table.
197. **A:** Validate and swap a new API only after successful loading.
198. **S:** Prevent unload while jobs reference old code.
199. **D:** Design state migration between two schema versions.
200. **C:** Build a host/plugin simulation with failed-reload rollback.

## Part VI — Capstone Engine

### Chapter 41 — Architecture and Constraints
201. **F:** Write a one-page engine constraint document.
202. **A:** Map subsystem dependencies and owners.
203. **S:** Define startup, failure, and shutdown order.
204. **D:** Remove one unnecessary abstraction from the design.
205. **C:** Produce an executable architecture skeleton with headless mode.

### Chapter 42 — Platform Layer
206. **F:** Define platform events independent of the window library.
207. **A:** Add monotonic time and sleep services.
208. **S:** Handle user-data and executable-relative paths correctly.
209. **D:** Specify the boundary for dynamic libraries and file watching.
210. **C:** Build native and headless platform backends behind one API.

### Chapter 43 — Renderer
211. **F:** Define renderer handles and command buffers.
212. **A:** Add resource creation and deferred destruction.
213. **S:** Track frames in flight and stale resources.
214. **D:** Separate renderer frontend from backend.
215. **C:** Build a validated software renderer backend for CI.

### Chapter 44 — Asset Pipeline
216. **F:** Hash a source file and importer version.
217. **A:** Compile one source format into a runtime artifact.
218. **S:** Rebuild dependents after a changed dependency.
219. **D:** Design deterministic artifact naming and cache layout.
220. **C:** Build an incremental asset compiler with manifest output.

### Chapter 45 — Runtime World
221. **F:** Spawn, update, and destroy world entities.
222. **A:** Add deterministic fixed-step simulation.
223. **S:** Serialize only durable state.
224. **D:** Separate authoring IDs from runtime handles.
225. **C:** Build a complete small-game runtime with replay tests.

### Chapter 46 — Editor
226. **F:** Represent an edit as a command.
227. **A:** Implement undo and redo stacks.
228. **S:** Make save atomic and recoverable.
229. **D:** Separate editor selection from runtime entities.
230. **C:** Build an editor shell supporting hierarchy, properties, save, and play mode.

### Chapter 47 — Profiling and Optimization
231. **F:** Record frame time and update count.
232. **A:** Add per-stage timing and memory counters.
233. **S:** Detect frame-time budget regressions.
234. **D:** Optimize only after a written hypothesis.
235. **C:** Build a benchmark scene and automated budget report.

### Chapter 48 — Packaging a Small Game
236. **F:** Stage executable, assets, config, and notices.
237. **A:** Generate a version and asset manifest.
238. **S:** Run from outside the source working directory.
239. **D:** Define save compatibility and update policy.
240. **C:** Produce a reproducible release archive with checksums and smoke tests.

## Completion rubric

A complete exercise submission should include:

1. a compiling package;
2. tests or assertions for normal and boundary behavior;
3. explicit ownership and cleanup notes;
4. deterministic inputs where practical;
5. a short design note for S, D, and C exercises;
6. benchmark evidence for performance claims;
7. no unexplained warnings or ignored failures.
