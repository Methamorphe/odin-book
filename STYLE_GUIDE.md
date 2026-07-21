# Odin Project Style Guide

> Conventions for readable, explicit, testable, and performance-aware Odin code.

This guide defines the house style used by this repository and the Threadline Engine project. It is intentionally opinionated. A project may choose different conventions, but it should choose them explicitly and apply them consistently.

The priorities are:

1. correctness and explicit invariants;
2. ownership and lifetime clarity;
3. simple control flow;
4. stable APIs and predictable failure;
5. data-oriented organization;
6. testability and determinism;
7. measured performance;
8. local consistency over personal preference.

---

## 1. Formatting

Use `odinfmt` when available for the compiler/toolchain version used by the project.

Do not manually align large blocks with spaces. Alignment creates noisy diffs when names or types change.

Prefer one statement per line. Keep expressions readable before trying to make them compact.

```odin
// Preferred
result := transform_position(
    entity.position,
    entity.rotation,
    parent_transform,
)

// Avoid
result := transform_position(entity.position, entity.rotation, parent_transform)
```

Use trailing commas in multiline literals and calls where supported. They reduce diff churn.

Keep files focused. A file should represent one coherent responsibility rather than an arbitrary line-count target.

---

## 2. Naming

### 2.1 General rules

Use names that describe domain meaning, not implementation trivia.

```odin
// Preferred
frame_allocator
asset_generation
pending_commands

// Avoid
fa
ag
tmp2
```

Short names are acceptable for conventional local scopes:

- `i`, `j` for small indices;
- `x`, `y`, `z` for coordinates;
- `dt` for delta time;
- `t` for a test context;
- `ok` for a single immediate success result.

Do not reuse `ok` repeatedly in one scope. Use meaningful status names when several operations occur.

```odin
asset, asset_registered := register_asset(...)
entity, entity_spawned := spawn_entity(...)
```

### 2.2 Types

Use `Title_Case` for structs, enums, unions, distinct types, and aliases.

```odin
Asset_Handle :: struct {
    index:      u32,
    generation: u32,
}

Load_Error :: enum {
    None,
    Not_Found,
    Invalid_Format,
}
```

Use domain-qualified names when a generic name would be ambiguous.

```odin
Renderer_Config
Audio_Config
Asset_State
Editor_Command
```

Avoid suffixing every type with `Data`, `Info`, `Manager`, or `Object`. Choose a name that states the actual role.

### 2.3 Procedures

Use `snake_case` procedure names.

```odin
load_asset :: proc(...)
resolve_handle :: proc(...)
extract_render_commands :: proc(...)
```

Use verbs for operations and nouns only for constructors or conversions whose meaning is obvious.

Preferred verb families:

- `init` / `shutdown` for lifecycle;
- `create` / `destroy` for owned runtime resources;
- `open` / `close` for external streams or handles;
- `load` / `unload` for persistent resources;
- `acquire` / `release` for reference-counted or pooled resources;
- `register` / `unregister` for registries;
- `add` / `remove` for collection membership;
- `get` for required lookup when failure semantics are explicit;
- `find` for optional search;
- `try_*` when failure is expected and non-exceptional;
- `is_*`, `has_*`, `can_*` for predicates;
- `encode` / `decode` for external representations;
- `serialize` / `deserialize` only when the format contract is established.

### 2.4 Constants

Use clear names that communicate units and scope.

```odin
MAX_ENTITIES       :: 16_384
FIXED_STEP_SECONDS :: 1.0 / 60.0
DEFAULT_PORT       :: 8080
```

Include units in names where confusion is possible:

```odin
timeout_ms
size_bytes
sample_rate_hz
angle_radians
```

### 2.5 Files and packages

Use lower-case package and file names. Prefer descriptive hyphen-free or underscore-separated paths compatible with project tooling.

```text
renderer/
    renderer.odin
    resource_pool.odin
    command_buffer.odin
```

Avoid generic package names such as `utils`, `common`, or `helpers`. They become dependency magnets. Name packages after a domain or capability.

---

## 3. Declarations and type choices

Prefer inference when the type is obvious and stable.

```odin
count := len(items)
```

Write the type when it communicates a contract, controls width, prevents unintended inference, or improves API readability.

```odin
fixed_dt: f32 = 1.0 / 60.0
asset_id: u64 = hash_path(path)
```

Use fixed-width integer types for:

- file formats;
- network protocols;
- ABI boundaries;
- persisted identifiers;
- GPU data;
- deterministic hashes.

Use `int` for ordinary in-memory indexing and counts unless a format or boundary requires a fixed width.

Use `distinct` types to prevent accidental mixing of semantically different scalar or handle values.

```odin
Entity_Id :: distinct u64
Asset_Id  :: distinct u64
```

Do not use `rawptr` outside narrow foreign, allocator, or type-erased boundaries.

---

## 4. Procedure design

### 4.1 Keep contracts narrow

A procedure should do one coherent operation and expose only the data required for it.

```odin
update_positions :: proc(positions: []Vec2, velocities: []Vec2, dt: f32)
```

Do not pass a full `App` or `World` merely because it is convenient if the procedure only needs two arrays.

### 4.2 Make mutation visible

Use pointers for mutable aggregate inputs.

```odin
world_step :: proc(world: ^World, dt: f32)
```

Prefer immutable slices and values for read-only inputs.

```odin
compute_bounds :: proc(points: []Vec3) -> Bounds
```

Avoid hidden mutation through package globals or implicit singleton access.

### 4.3 Return values

Use multiple returns when the values form one immediate result.

```odin
entity, spawned := spawn_entity(&world, transform)
```

Use an output structure when the result has many fields, evolves independently, or must be stored.

```odin
Load_Result :: struct {
    asset:       Asset,
    error:       Load_Error,
    bytes_read:  int,
    dependencies: [dynamic]Asset_Id,
}
```

Do not return borrowed slices or strings without documenting their lifetime.

### 4.4 Parameter order

Use this order where practical:

1. mutable owner or destination;
2. required inputs;
3. optional configuration;
4. allocator or execution context.

```odin
decode_image :: proc(
    dst: ^Image,
    encoded: []byte,
    options: Decode_Options = {},
    allocator := context.allocator,
) -> Decode_Error
```

### 4.5 Default parameters

Use defaults only for values that are safe, unsurprising, and stable.

Do not hide important ownership, durability, thread-safety, or performance decisions behind defaults.

---

## 5. Ownership and lifetime

Every allocation must have an identifiable owner and release point.

For each stored pointer, slice, string, dynamic array, map, or foreign handle, the code should make clear:

- who created it;
- who may mutate it;
- how long it remains valid;
- who releases it;
- whether it can move or be invalidated.

### 5.1 Prefer same-side allocation and release

```odin
asset_init(&asset, allocator)
defer asset_destroy(&asset)
```

Across package, thread, plugin, or foreign boundaries, allocate and free on the same side whenever possible.

### 5.2 Borrowing

Borrowed data should not outlive the call unless the API states otherwise.

```odin
process_bytes :: proc(data: []byte)
```

If a subsystem retains the data, reflect that in the name and documentation and usually copy it into subsystem-owned storage.

### 5.3 Temporary memory

Temporary allocators must have explicit reset boundaries such as:

- end of frame;
- end of request;
- end of import job;
- end of command execution.

Never return or enqueue references into temporary memory that may reset before use.

### 5.4 Stable identity

Use generation-checked handles or stable IDs for long-lived references into movable storage.

Do not expose pointers into dynamic arrays, dense component stores, or resource pools when later insertions or removals may invalidate them.

### 5.5 Capacity

Bounded systems must expose capacity failure.

```odin
spawn_entity :: proc(world: ^World, transform: Transform) -> (Entity, bool)
```

Never silently overwrite live entries or grow critical structures without a documented allocation policy.

---

## 6. Error handling

Use the simplest error representation that preserves actionable information.

### 6.1 Boolean results

Use `(value, bool)` for optional lookup or simple expected failure.

```odin
value, found := find_setting(settings, key)
```

### 6.2 Error enums

Use enums when callers need to distinguish failure classes.

```odin
Save_Error :: enum {
    None,
    Permission_Denied,
    Out_Of_Space,
    Invalid_State,
}
```

Reserve `.None` for success when it simplifies call sites and the convention is consistent.

### 6.3 Diagnostics

Separate stable machine-readable error categories from rich diagnostics.

```odin
result, err := load_asset(...)
if err != .None {
    log_asset_error(path, err)
}
```

Do not make callers parse human-readable strings to determine behavior.

### 6.4 Assertions

Assertions are for broken internal invariants, impossible branches, and programmer errors.

Do not assert on:

- missing user files;
- malformed network input;
- capacity exhaustion that can occur normally;
- unsupported user-selected formats;
- recoverable platform failures.

### 6.5 Cleanup

Acquire a resource, verify success, then immediately schedule cleanup.

```odin
file, err := open_file(path)
if err != .None {
    return err
}
defer close_file(file)
```

Keep cleanup in reverse ownership order.

---

## 7. Data structures and layout

Choose data layout from access patterns, not from how a conceptual object is described.

### 7.1 AoS and SoA

Use array-of-structures when operations usually consume complete records.

Use structure-of-arrays when hot loops process a few fields across many records.

Measure with representative data sizes and build modes before claiming a layout is faster.

### 7.2 Dense storage

Prefer dense iteration for hot components and resources. Use sparse mappings or handles to preserve identity.

When swap-removing, update every reverse mapping in the same operation and test the invariant.

### 7.3 Maps

Use maps for associative lookup, not as a universal container.

Do not rely on map iteration order. Sort extracted keys when deterministic output is required.

### 7.4 Dynamic arrays

Document whether order is stable. Reserve capacity when an expected upper bound is known and measurement shows growth matters.

Release owned dynamic arrays at the owner’s shutdown boundary.

### 7.5 Strings

Treat strings as immutable views. Do not retain strings backed by temporary, parser, or foreign memory after that memory becomes invalid.

Use byte operations only when the format is explicitly byte-oriented. Use rune iteration for Unicode text semantics.

---

## 8. Control flow

Prefer early returns for invalid input and failed preconditions.

```odin
load :: proc(path: string) -> Load_Error {
    if len(path) == 0 {
        return .Invalid_Path
    }
    if !is_supported(path) {
        return .Unsupported_Format
    }

    // Main path remains shallow.
    return .None
}
```

Keep the successful path visually clear.

Avoid deeply nested conditionals and callback chains. Extract named procedures when they represent a real domain operation, not merely to reduce line count.

Use `switch` for closed state machines and enums. Handle all meaningful states explicitly.

```odin
switch asset.state {
case .Unloaded:
case .Queued:
case .Loading:
case .Ready:
case .Failed:
}
```

Do not use `defer` for surprising control flow. Use it for local cleanup and restoration.

---

## 9. Package architecture

Dependencies should point inward toward stable domain contracts.

A typical native application may use:

```text
app
├── platform
├── runtime
│   ├── world
│   ├── assets
│   └── simulation
├── renderer
├── audio
└── tools
```

### 9.1 Package boundaries

A package should own:

- one coherent set of invariants;
- its private representation;
- initialization and cleanup for its resources;
- tests for its contracts.

Avoid circular dependencies. Introduce a smaller shared contract package only when the contract is genuinely stable and domain-specific.

### 9.2 Public surface

Keep exported names minimal. Do not export fields solely to make tests or unrelated packages convenient.

Prefer procedures that preserve package invariants over direct external mutation.

### 9.3 Globals

Avoid mutable global state. Acceptable globals include:

- immutable constants;
- static lookup tables;
- generated read-only metadata;
- carefully isolated platform entry state when required by a foreign API.

Do not hide allocators, mutable registries, runtime worlds, or configuration in globals.

---

## 10. Allocators

Allocator choice is part of API and architecture design.

Use:

- heap or long-lived allocator for durable application state;
- arena for grouped lifetime;
- frame/request allocator for temporary work;
- pool for fixed-size reusable objects;
- caller-provided buffers for bounded conversion or encoding.

Pass an allocator when the caller needs control. Use `context.allocator` for conventional local allocation when the ownership policy is already clear.

Do not change `context.allocator` across a broad or asynchronous scope without restoring it and documenting the lifetime.

Do not allocate in hot loops by default. First design the lifetime, then measure whether allocation matters.

---

## 11. Concurrency

Prefer isolated ownership and message passing over unrestricted shared mutation.

### 11.1 Thread ownership

Document which thread owns each subsystem and which procedures may run concurrently.

Typical ownership:

- platform events: main thread;
- rendering submission: render thread or main thread;
- audio callback: audio thread with real-time restrictions;
- asset decode: worker threads;
- world mutation: simulation phase only.

### 11.2 Synchronization

Use a mutex when it makes the invariant obvious. Use atomics only for small state transitions with documented memory-order reasoning.

Never hold a lock while:

- performing blocking I/O;
- invoking unknown callbacks;
- waiting for another job that may need the same lock;
- logging through a potentially reentrant system.

### 11.3 Jobs

Job payloads must remain valid until completion. Frame arenas may be used only when all jobs reach a barrier before reset.

Merge parallel results in a deterministic order when output order affects state, serialization, rendering, or tests.

### 11.4 Real-time code

In audio callbacks and similar real-time paths:

- do not allocate;
- do not lock contended mutexes;
- do not perform file or network I/O;
- do not log synchronously;
- use bounded work and preallocated queues.

---

## 12. Testing

Every package with non-trivial invariants should have tests.

Prioritize tests for:

- boundary values;
- invalid input;
- stale handles;
- capacity exhaustion;
- cleanup after partial initialization;
- serialization round trips;
- version rejection and migration;
- deterministic simulation;
- concurrency state transitions;
- swap-remove mappings.

Name tests after behavior.

```odin
@(test)
test_destroyed_handle_does_not_resolve :: proc(t: ^testing.T)
```

Do not make unit tests depend on wall-clock timing, internet access, random external state, or developer-specific paths.

Use fixed seeds for randomized tests and print the seed on failure.

A bug fix should include a regression test when practical.

---

## 13. Logging and diagnostics

Log events that help reconstruct system behavior:

- lifecycle transitions;
- external resource failures;
- version and compatibility decisions;
- asset state changes;
- recovery and fallback behavior;
- performance budget violations.

Avoid logging every element in hot loops.

Include stable context fields such as subsystem, operation, entity or asset ID, path, version, and error category.

Never log secrets, authentication tokens, private user content, or unbounded network payloads.

Use severity consistently:

- trace: high-volume development detail;
- debug: useful state for diagnosis;
- info: major normal lifecycle events;
- warning: degraded but recoverable behavior;
- error: failed operation requiring attention;
- fatal: process cannot preserve core invariants.

---

## 14. Performance

Correctness and clarity come first. Optimize measured bottlenecks.

Before changing code for performance:

1. define the workload;
2. select the metric;
3. collect a baseline;
4. profile the actual build mode;
5. change one relevant factor;
6. verify correctness;
7. repeat measurements;
8. record trade-offs.

Use release-oriented builds for performance comparisons.

Benchmarks must:

- perform enough work to exceed timer noise;
- include a checksum or observable result;
- separate setup from measured work;
- compare equivalent semantics;
- report compiler version, target, build flags, and machine;
- avoid treating CI timing as a stable performance baseline.

Do not obscure code with micro-optimizations that are not supported by profiling evidence.

---

## 15. Serialization and persistence

Persist explicit formats, not accidental in-memory layouts.

Every durable format should define:

- magic or format identity;
- version;
- byte order;
- field widths;
- size and count limits;
- validation order;
- migration policy;
- compatibility guarantees.

Encode and decode field by field unless raw layout is deliberately specified and tested.

Validate lengths and multiplication overflow before allocating.

Write important files atomically and preserve the previous valid version until replacement succeeds.

Never migrate the only copy of a save file in place.

---

## 16. Foreign interfaces and plugins

Keep foreign code behind narrow project-owned wrappers.

Across ABI boundaries, prefer:

- fixed-width scalar types;
- C calling conventions;
- plain documented structures;
- opaque handles;
- pointer-plus-length pairs;
- explicit API versions;
- same-side allocation and release.

Do not pass Odin dynamic arrays, maps, closures, allocator internals, or unstable language-specific representations across a plugin boundary.

Do not unload a dynamic library while jobs, callbacks, objects, or queues may still contain pointers into its code.

Validate a replacement plugin before switching away from the old one.

---

## 17. Platform, renderer, and engine conventions

### 17.1 Platform layer

The platform package should expose events and services, not leak OS-specific types throughout the runtime.

Convert native events into project-owned event types at the boundary.

### 17.2 Runtime world

Simulation owns authoritative world state. Rendering, audio, and tools consume derived snapshots, commands, or handles.

Do not make GPU resources or editor widgets authoritative gameplay state.

### 17.3 Renderer

Use opaque renderer handles. Validate generations before accessing resource slots.

Build render commands from world state, sort or batch them explicitly, and submit them through a narrow renderer API.

### 17.4 Assets

Separate stable asset identity from loaded runtime resources.

Use an explicit state machine and retain diagnostics for failed loads. Asset imports must be deterministic for the same source, settings, tool version, and target.

### 17.5 Editor

Route modifications through commands to support undo, redo, validation, logging, and collaboration.

Do not let arbitrary UI widgets directly mutate deep runtime state.

---

## 18. Comments and documentation

Comments should explain:

- invariants;
- ownership and lifetime;
- non-obvious algorithmic choices;
- synchronization reasoning;
- format contracts;
- compatibility decisions;
- why a simpler-looking alternative is unsafe.

Do not narrate obvious syntax.

```odin
// Increment before slot reuse so stale handles cannot resolve to the new object.
generations[index] += 1
```

Public APIs should document:

- purpose;
- mutation;
- ownership;
- returned lifetime;
- normal failures;
- thread-safety;
- capacity or complexity when important.

Keep TODOs actionable and scoped.

```odin
// TODO(issue-142): preserve unknown fields during settings migration.
```

Avoid permanent vague TODOs such as `// fix later`.

---

## 19. Review checklist

Before merging Odin code, verify:

### Correctness

- Are invalid inputs handled?
- Are integer ranges and conversions checked?
- Are capacity and overflow cases explicit?
- Are partial initialization paths cleaned up?

### Ownership

- Does every allocation have an owner?
- Are borrowed lifetimes clear?
- Can stored pointers or slices be invalidated?
- Can temporary memory escape its scope?

### API

- Is mutation visible?
- Are failures actionable?
- Is the public surface minimal?
- Are units and ordering guarantees documented?

### Data and performance

- Does the layout match access patterns?
- Is ordering deterministic where required?
- Are optimizations supported by measurements?
- Are hot-path allocations intentional?

### Concurrency

- Is thread ownership documented?
- Can jobs outlive their payload memory?
- Are locks bounded and free of unknown callbacks?
- Is result merging deterministic where necessary?

### Tests

- Are core invariants tested?
- Is there a regression test for the bug being fixed?
- Do tests avoid machine-specific state and wall-clock timing?

### Maintenance

- Are names domain-specific?
- Does the package own one coherent responsibility?
- Are comments explaining why rather than what?
- Does formatting match the rest of the repository?

---

## 20. Intentional exceptions

Style rules are tools, not substitutes for judgment. An exception is acceptable when it:

- improves a measured hot path;
- matches a required foreign ABI;
- preserves compatibility with an established format;
- isolates platform-specific constraints;
- materially simplifies a local implementation.

Document the reason near the exception or in the package design notes. Do not spread a boundary-specific compromise through the rest of the codebase.

For practical examples of these conventions, see [COOKBOOK.md](COOKBOOK.md), the chapter examples in `examples/`, and the Threadline Engine in `projects/engine/`.
