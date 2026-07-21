# Chapter 27 — API Design in Odin

[← Chapter 26: Reflection and Compile-Time Features](26-reflection-compile-time.md) · [Exercises](../exercises/27-api-design.md) · [Part IV: Data-Oriented Design →](28-data-transformations.md)

An API is a set of promises about values, ownership, errors, mutation, performance, and evolution. In Odin, good APIs make these promises explicit rather than relying on constructors, hidden exceptions, or implicit allocation.

## 27.1 Design from the caller

Start with the smallest useful call site. Ask what the caller must know, what can fail, what allocates, and which values remain valid after the call.

```odin
asset_load :: proc(
    path: string,
    allocator := context.allocator,
) -> (Asset, Asset_Error)
```

The signature already communicates input, allocation policy, result, and error domain.

## 27.2 Package boundaries

A package should own one coherent responsibility. Its public surface should be smaller than its implementation. Keep internal helpers unexported and avoid packages that merely collect unrelated utilities.

Dependency direction should follow policy: domain packages should not import platform, UI, or vendor bindings directly.

## 27.3 Initialization and cleanup

Prefer paired operations:

```odin
renderer_init :: proc(renderer: ^Renderer, desc: Renderer_Desc) -> Renderer_Error
renderer_destroy :: proc(renderer: ^Renderer)
```

After failed initialization, define whether cleanup is required. After destruction, reset handles where practical so repeated cleanup is safe and stale use is easier to detect.

## 27.4 Ownership in signatures

Odin does not encode every ownership rule in the type system, so naming and documentation matter.

State whether inputs are:

- borrowed for the duration of the call;
- retained after the call;
- consumed and invalid afterward;
- copied into caller-provided or allocator-provided storage.

A returned slice must state who owns its backing memory and how long it remains valid.

## 27.5 Mutation

Use values for small immutable data and pointers for intentional mutation. Avoid taking a pointer merely to imitate methods.

```odin
camera_move :: proc(camera: ^Camera, delta: Vec3)
camera_forward :: proc(camera: Camera) -> Vec3
```

The distinction is visible at the call site.

## 27.6 Configuration structures

When a procedure has many optional parameters, use a descriptor:

```odin
Window_Desc :: struct {
    title:     string = "Odin App",
    width:     int = 1280,
    height:    int = 720,
    resizable: bool = true,
}
```

Descriptors support named fields and future extension. Validate them once at the boundary.

## 27.7 Errors as domain values

Define errors at the abstraction level of the package:

```odin
Asset_Error :: enum {
    None,
    Not_Found,
    Unsupported_Format,
    Invalid_Data,
    Out_Of_Memory,
}
```

Preserve lower-level diagnostic context separately when useful. Do not leak every operating-system code into every caller.

## 27.8 Result shape

Use multiple returns for compact operations and tagged unions or result structs when more context is needed. Choose one convention consistently within a package.

A boolean should answer one unambiguous question. If `false` could mean missing, invalid, cancelled, or full, use an error type instead.

## 27.9 Allocator policy

Procedures that allocate should either:

- accept an allocator;
- clearly use `context.allocator`;
- allocate inside a caller-owned arena or object;
- return data backed by explicitly borrowed storage.

Hidden allocation is a performance and ownership contract even when the signature does not show it.

## 27.10 Caller-provided buffers

For hot paths or bounded systems, caller-provided storage is often ideal:

```odin
format_status :: proc(dst: []u8, status: Status) -> (written: int, ok: bool)
```

Document required capacity and truncation behavior. Do not silently allocate when the buffer is too small unless the API promises that fallback.

## 27.11 Handles instead of pointers

Public handles decouple clients from internal storage and make stale-reference detection possible:

```odin
Texture_Handle :: distinct u32
texture_get :: proc(store: ^Texture_Store, handle: Texture_Handle) -> (^Texture, bool)
```

Use generations when slots can be reused.

## 27.12 Stable identifiers and indexes

An array index is not automatically a stable identity. Distinguish temporary positions, persistent IDs, and opaque handles with distinct types.

This prevents accidental use of a serialized ID as an in-memory index.

## 27.13 Batches and data-oriented APIs

A batch API often outperforms repeated scalar calls and makes synchronization explicit:

```odin
transforms_update :: proc(
    positions: []Vec3,
    velocities: []Vec3,
    dt: f32,
)
```

Design around the data transformation when callers naturally process collections.

## 27.14 Callbacks versus queues

Callbacks are immediate and convenient but can create reentrancy and lifetime problems. Event queues defer handling and centralize ordering. Choose based on execution semantics, not fashion.

Document whether callbacks may occur synchronously, from another thread, or after deregistration begins.

## 27.15 Versioning and compatibility

Public APIs evolve. Prefer additive descriptor fields with defaults, opaque handles, reserved enum values where protocols require them, and explicit format versions.

Breaking source compatibility can be acceptable in a young project, but make it deliberate and documented.

## 27.16 Naming

Names should expose domain meaning and operation direction:

- `asset_load`, `asset_unload`;
- `queue_push`, `queue_pop`;
- `parser_init`, `parser_next`;
- `world_entity_create`.

Avoid vague verbs such as `process`, `handle`, or `manage` unless the domain supplies the missing meaning.

## 27.17 Performance contracts

Document important complexity and behavior:

- whether a call allocates;
- expected complexity;
- whether it blocks;
- thread safety;
- pointer invalidation;
- iteration order;
- cache or lifetime effects.

A fast implementation with an undocumented invalidation rule is not a good API.

## 27.18 Testing public contracts

Test through the public surface. Protect initialization, cleanup, error translation, ownership, boundary sizes, repeated operations, and compatibility. Internal refactoring should not require rewriting every contract test.

## 27.19 Review checklist

Before publishing an API, ask:

- Who owns every pointer, slice, string, and handle?
- What can fail and how is it reported?
- Does the call allocate or block?
- What remains valid after mutation?
- Is thread safety explicit?
- Can the implementation evolve behind the boundary?
- Are names understandable at the call site?

## 27.20 Common mistakes

### Returning borrowed data without a lifetime statement

Callers may retain data beyond the next mutation or frame.

### Exporting implementation structs

Clients become coupled to field layout and internal invariants.

### Using globals for convenience

Testing, multiple instances, and concurrency become harder.

### Adding abstraction before a stable pattern exists

Design from real call sites, then generalize repeated contracts.

## 27.21 Chapter checklist

You should now be able to:

- design package surfaces from caller needs;
- express ownership, mutation, allocation, and errors;
- use descriptors, handles, and caller-provided buffers;
- choose callbacks, queues, scalar, or batch APIs;
- document performance and thread-safety contracts;
- evolve APIs intentionally.

## References

- [Odin package documentation](https://pkg.odin-lang.org/)
- [Semantic Versioning](https://semver.org/)
- [API Design for C](https://nullprogram.com/blog/2014/05/19/)

---

[Exercises](../exercises/27-api-design.md) · [Solutions](../solutions/27-api-design.md)