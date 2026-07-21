# Appendix C — C, C++, Go, and Rust Translation Notes

[← Appendix B: Standard-Library Field Guide](appendix-b-standard-library-field-guide.md) · [Appendix D: Exercise Index →](appendix-d-exercise-index.md)

This appendix helps experienced programmers transfer concepts into Odin without forcing another language’s design habits onto it.

## C.1 General rule

Translate intent, ownership, and data flow—not syntax line by line. Odin often prefers explicit values, allocator-aware APIs, package-level procedures, slices, and data-oriented layouts over object hierarchies or implicit runtime machinery.

## C.2 From C

### Familiar ideas

C programmers will recognize:

- explicit memory and layout;
- pointers and address arithmetic at low-level boundaries;
- foreign calling conventions;
- compilation to native code;
- direct operating-system access;
- plain structs and procedure-oriented design.

### Important differences

Odin adds:

- slices with length;
- dynamic arrays and maps;
- tagged unions;
- multiple return values;
- `defer`;
- packages;
- polymorphic procedures;
- built-in reflection and context;
- safer defaults around declarations and conversions.

### C arrays versus Odin slices

C:

```c
void process(float *values, size_t count);
```

Odin:

```odin
process :: proc(values: []f32) {}
```

Use pointer-plus-length only at ABI boundaries. Convert to a slice immediately after validation.

### C error codes

C:

```c
int load(const char *path, Asset *out_asset);
```

Odin:

```odin
load :: proc(path: string) -> (Asset, Load_Error)
```

Multiple return values make the success value and error explicit without output parameters.

### C cleanup labels

C often uses `goto cleanup`. Odin usually places `defer` directly after each successful acquisition.

## C.3 From C++

### Do not recreate classes automatically

A C++ class often combines:

- storage;
- invariants;
- methods;
- ownership;
- polymorphism;
- allocation policy.

In Odin, separate these concerns deliberately. Use a struct for data and package procedures for behavior.

```odin
Camera :: struct {
    position: [3]f32,
    fov: f32,
}

camera_update :: proc(camera: ^Camera, input: Input, dt: f32) {}
```

### Constructors and destructors

Use explicit initialization and destruction procedures when resources are owned:

```odin
renderer_init :: proc(config: Renderer_Config) -> (Renderer, Init_Error)
renderer_destroy :: proc(renderer: ^Renderer)
```

Pair successful initialization with `defer renderer_destroy(&renderer)`.

### RAII

Odin does not rely on implicit destructors. This makes cleanup visible and avoids hidden work, but it requires discipline.

### Inheritance

Prefer:

- tagged unions for closed variant sets;
- procedure tables for runtime behavior;
- composition for shared data;
- handles and registries for engine resources;
- ECS or data tables for large homogeneous populations.

### Templates

Use polymorphic procedures and compile-time parameters for focused generic algorithms. Avoid building a metaprogramming framework where ordinary procedures and explicit code are clearer.

### STL containers

Map common C++ containers approximately as follows:

- `std::array<T, N>` → `[N]T`;
- `std::span<T>` → `[]T` or `[]const T`;
- `std::vector<T>` → `[dynamic]T`;
- `std::unordered_map<K,V>` → `map[K]V`;
- `std::variant` → `union`;
- `std::optional<T>` → union or `(T, bool)` depending on semantics.

Ownership and iterator invalidation still require explicit design.

## C.4 From Go

### Familiar ideas

Go programmers will recognize:

- package-oriented organization;
- multiple return values;
- slices;
- simple control flow;
- explicit error handling;
- preference for composition.

### Key differences

Odin has:

- manual and allocator-aware memory management;
- no garbage collector requirement;
- tagged unions;
- distinct types;
- stronger layout control;
- foreign ABI support;
- compile-time conditionals;
- explicit threading and synchronization rather than goroutines as the default model.

### Slices

Go slices and Odin slices are both views, but an Odin slice does not keep a garbage-collected backing array alive. The owner’s lifetime must remain valid.

### Interfaces

Do not translate every Go interface into a procedure table. Many Odin APIs are clearer as concrete data plus procedures. Use a procedure table only when runtime substitution is truly required.

### Goroutines and channels

Translate the architecture, not the syntax. Options include:

- a fixed worker pool;
- a job graph;
- bounded queues;
- dedicated I/O threads;
- explicit synchronization.

Define backpressure and shutdown behavior.

### `defer`

Both languages have `defer`, but confirm scope and argument-evaluation behavior. Keep cleanup near acquisition and avoid relying on large deferred stacks in hot loops.

## C.5 From Rust

### Familiar ideas

Rust programmers will recognize:

- tagged unions;
- exhaustive switching;
- explicit result handling;
- newtypes and distinct domain identifiers;
- strong concern for ownership and lifetime;
- zero-cost native abstractions.

### Key differences

Odin does not enforce ownership and borrowing through a borrow checker. Lifetime correctness is a design responsibility supported by conventions, APIs, tests, and careful storage choices.

### References and slices

Rust:

```rust
fn sum(values: &[i32]) -> i32
```

Odin:

```odin
sum :: proc(values: []const i32) -> i32
```

The Odin type expresses read-only access but not a statically checked lifetime relationship.

### `Result<T, E>`

Translate to multiple returns or a union depending on the domain:

```odin
parse :: proc(text: string) -> (Value, Parse_Error)
```

Use an enum error when no payload is needed and a struct or union when diagnostics require data.

### Traits

Possible Odin translations include:

- concrete procedures;
- compile-time polymorphism;
- a procedure table plus user data;
- a tagged union;
- separate system tables.

Choose based on whether variation is compile-time, runtime, open, or closed.

### `Option<T>`

Use `(T, bool)` for lookup-like operations, a nil pointer for optional borrowed objects when appropriate, or a tagged union when absence is one of several meaningful states.

### Unsafe code

Odin’s low-level operations are more broadly available, so create your own safety boundaries. Keep raw pointers, transmutation, and foreign memory in small reviewed packages.

## C.6 Object-oriented translation patterns

Instead of:

```text
BaseResource
  ├─ Texture
  ├─ Mesh
  └─ Sound
```

consider:

```text
Resource_Handle
Resource_Kind
Texture_Table
Mesh_Table
Sound_Table
```

The second form makes storage and iteration explicit and often fits engine workloads better.

## C.7 Exception translation

Odin does not use exceptions as the ordinary error model. Translate exceptions into:

- explicit error return values;
- transactional state changes;
- cleanup with `defer`;
- diagnostics at subsystem boundaries;
- panic only for unrecoverable programmer failures.

## C.8 Smart-pointer translation

Ask what ownership is actually needed:

- unique owner → explicit struct owner and destroy procedure;
- shared immutable data → registry handle and reference count if required;
- temporary borrow → pointer or slice with documented lifetime;
- stable engine object → generational handle;
- tree ownership → parent-owned storage with explicit destruction.

Do not reproduce reference counting merely because the source language used it.

## C.9 Iterator translation

For hot data, prefer direct loops over contiguous slices:

```odin
for value, i in values {
    // ...
}
```

Use iterator-like state machines when traversal is lazy, expensive, or structurally complex. Avoid abstraction that hides allocation or pointer chasing.

## C.10 Build-system translation

CMake, Cargo, and Go modules solve different ecosystems. An Odin project should pin:

- compiler version;
- collections and foreign dependencies;
- generated bindings;
- asset tools;
- target-specific linker inputs;
- CI commands;
- release scripts.

Keep one documented command for checks and one for release packaging.

## C.11 Translation checklist

Before porting a subsystem, identify:

1. who owns each allocation;
2. which values are stable and which may move;
3. whether variation is runtime or compile-time;
4. whether the workload benefits from contiguous tables;
5. which errors are expected;
6. what cleanup is required;
7. where foreign ABI types stop;
8. what determinism is required;
9. what must be measured before optimization.

## C.12 Final guidance

The best Odin translation usually becomes simpler after removing assumptions inherited from another runtime. Keep the data visible, make ownership explicit, isolate unsafe boundaries, and design around the work the program performs.
