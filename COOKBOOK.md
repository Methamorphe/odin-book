# The Odin Programming Cookbook

> Practical recipes for common systems-programming tasks in Odin.

This cookbook complements the main book. It is organized around small tasks you may need while building tools, servers, native applications, games, and engine code.

The snippets favor explicit ownership, bounded work, deterministic behavior, and narrow interfaces. They are starting points rather than universal abstractions: verify package APIs against the Odin version used by your project.

## Contents

1. [Program structure](#1-program-structure)
2. [Arguments and configuration](#2-arguments-and-configuration)
3. [Strings and parsing](#3-strings-and-parsing)
4. [Files and paths](#4-files-and-paths)
5. [Collections](#5-collections)
6. [Memory and lifetime](#6-memory-and-lifetime)
7. [Errors and diagnostics](#7-errors-and-diagnostics)
8. [Testing](#8-testing)
9. [Concurrency](#9-concurrency)
10. [Data-oriented patterns](#10-data-oriented-patterns)
11. [Binary data and interoperability](#11-binary-data-and-interoperability)
12. [Game and engine patterns](#12-game-and-engine-patterns)

---

## 1. Program structure

### 1.1 Minimal executable

```odin
package main

import "core:fmt"

main :: proc() {
    fmt.println("hello, Odin")
}
```

Run it with:

```bash
odin run .
```

### 1.2 Explicit application lifecycle

Use one owner for subsystem initialization and cleanup.

```odin
App :: struct {
    running: bool,
    frame:   u64,
}

app_init :: proc(app: ^App) -> bool {
    app^ = App{running = true}
    return true
}

app_update :: proc(app: ^App) {
    app.frame += 1
    if app.frame >= 60 {
        app.running = false
    }
}

app_shutdown :: proc(app: ^App) {
    app.running = false
}

main :: proc() {
    app: App
    if !app_init(&app) {
        return
    }
    defer app_shutdown(&app)

    for app.running {
        app_update(&app)
    }
}
```

This pattern keeps ownership visible and shutdown order predictable.

### 1.3 Package-local helper

Keep implementation details unexported by naming them with lower-case identifiers.

```odin
normalize_name :: proc(name: string) -> string {
    return name
}

User :: struct {
    name: string,
}
```

---

## 2. Arguments and configuration

### 2.1 Read command-line arguments

```odin
package main

import "core:fmt"
import "core:os"

main :: proc() {
    args := os.args
    if len(args) < 2 {
        fmt.println("usage: app <input>")
        return
    }

    fmt.println("input:", args[1])
}
```

Treat arguments as untrusted input. Validate count, accepted values, ranges, and file locations before use.

### 2.2 Parse an integer

```odin
import "core:strconv"

parse_port :: proc(text: string) -> (u16, bool) {
    value, ok := strconv.parse_u64(text)
    if !ok || value == 0 || value > 65535 {
        return 0, false
    }
    return u16(value), true
}
```

Convert only after range validation.

### 2.3 Configuration precedence

Use a deterministic order:

```text
built-in defaults
→ configuration file
→ environment variables
→ command-line arguments
```

Keep the merge explicit:

```odin
Config :: struct {
    width:  int,
    height: int,
    debug:  bool,
}

config_defaults :: proc() -> Config {
    return Config{width = 1280, height = 720}
}
```

Validate the final merged configuration once before subsystem initialization.

---

## 3. Strings and parsing

### 3.1 Compare strings

```odin
if command == "build" {
    // ...
}
```

Remember that a `string` is a view. Copy it when its backing storage will not outlive the stored reference.

### 3.2 Build formatted text

```odin
import "core:fmt"

message := fmt.tprintf("entity=%d generation=%d", index, generation)
```

Temporary formatted strings should not be retained beyond the lifetime of their temporary storage.

### 3.3 Split a simple key-value line

```odin
import "core:strings"

parse_pair :: proc(line: string) -> (key, value: string, ok: bool) {
    index := strings.index_byte(line, '=')
    if index < 0 {
        return "", "", false
    }

    key = strings.trim_space(line[:index])
    value = strings.trim_space(line[index+1:])
    return key, value, len(key) > 0
}
```

For real configuration formats, define escaping, quoting, comments, duplicate keys, and encoding rules instead of silently guessing.

### 3.4 Iterate Unicode code points

```odin
for rune, byte_index in text {
    _ = byte_index
    // rune is a Unicode code point
}
```

Do not index UTF-8 text by byte when the operation is defined in characters.

---

## 4. Files and paths

### 4.1 Read an entire small file

```odin
import "core:os"

read_small_file :: proc(path: string) -> ([]byte, bool) {
    data, ok := os.read_entire_file(path)
    if !ok {
        return nil, false
    }
    return data, true
}
```

The returned allocation needs a documented owner and release point. Avoid whole-file reads for unbounded or attacker-controlled input.

### 4.2 Write a file atomically

A robust save operation is:

1. write to a temporary file in the destination directory;
2. flush and close it;
3. rename it over the destination;
4. preserve the previous file until the new write succeeds.

```text
settings.json.tmp → settings.json
```

This prevents a partial write from destroying the only valid copy.

### 4.3 Resolve data independently of the working directory

Do not assume the process starts from the project or executable directory. Resolve immutable data from an explicit data root and writable data from the platform user-data directory.

```odin
Runtime_Paths :: struct {
    data_root: string,
    user_root: string,
    log_root:  string,
}
```

Pass this structure into subsystems rather than reading global paths throughout the codebase.

### 4.4 Bound file input

```odin
MAX_CONFIG_BYTES :: 1024 * 1024
```

Check metadata or stop reading when the maximum accepted size is reached. A parser limit is part of the public input contract.

---

## 5. Collections

### 5.1 Append to a dynamic array

```odin
values: [dynamic]int
append(&values, 10)
append(&values, 20)
defer delete(values)
```

Check the return value when using APIs or compiler versions where allocation failure is reported explicitly.

### 5.2 Remove without preserving order

For dense storage, swap the last element into the removed slot.

```odin
remove_swap :: proc(values: ^[dynamic]int, index: int) -> bool {
    if index < 0 || index >= len(values^) {
        return false
    }

    last := len(values^) - 1
    values^[index] = values^[last]
    values^ = values^[:last]
    return true
}
```

Document that order is unstable.

### 5.3 Stable removal

When order matters, shift the tail left. This is O(n), so choose it deliberately.

```odin
remove_ordered :: proc(values: ^[dynamic]int, index: int) -> bool {
    if index < 0 || index >= len(values^) {
        return false
    }

    copy(values^[index:], values^[index+1:])
    values^ = values^[:len(values^)-1]
    return true
}
```

### 5.4 Map lookup

```odin
scores: map[string]int
scores["ada"] = 42

score, found := scores["ada"]
if found {
    _ = score
}
```

Do not use a zero value to infer whether a key exists.

### 5.5 Deduplicate while preserving first occurrence

```odin
deduplicate :: proc(input: []int, allocator := context.allocator) -> [dynamic]int {
    seen: map[int]bool
    result: [dynamic]int

    for value in input {
        if seen[value] {
            continue
        }
        seen[value] = true
        append(&result, value)
    }

    return result
}
```

For bounded integer domains, a bit set or fixed boolean array may be faster and simpler than a map.

---

## 6. Memory and lifetime

### 6.1 Caller-owned output buffer

```odin
encode_header :: proc(dst: []byte, kind: u16, size: u32) -> (written: int, ok: bool) {
    if len(dst) < 6 {
        return 0, false
    }

    // Write using an explicitly documented byte order.
    return 6, true
}
```

This avoids hidden allocation and lets the caller choose stack, arena, pool, or heap storage.

### 6.2 Temporary allocator scope

Use a temporary allocator for frame-local or request-local work, then reset it at one known boundary.

```odin
process_frame :: proc(frame_allocator: mem.Allocator) {
    previous := context.allocator
    context.allocator = frame_allocator
    defer context.allocator = previous

    // All default allocations in this scope belong to the frame.
}
```

Never retain a pointer or slice into temporary memory after reset.

### 6.3 Fixed-capacity pool

```odin
MAX_ITEMS :: 1024

Pool :: struct {
    items:  [MAX_ITEMS]Item,
    active: [MAX_ITEMS]bool,
}
```

Fixed-capacity pools are useful when limits are known and allocation during critical phases is undesirable. Return an explicit capacity error instead of overwriting live data.

### 6.4 Generation-checked handle

```odin
Handle :: struct {
    index:      u32,
    generation: u32,
}

is_valid :: proc(generations: []u32, active: []bool, h: Handle) -> bool {
    index := int(h.index)
    return index >= 0 &&
           index < len(generations) &&
           active[index] &&
           generations[index] == h.generation
}
```

Increment the slot generation when an object is destroyed before reusing the slot.

---

## 7. Errors and diagnostics

### 7.1 Boolean success for simple failure

```odin
find_index :: proc(values: []int, target: int) -> (int, bool) {
    for value, index in values {
        if value == target {
            return index, true
        }
    }
    return 0, false
}
```

Use this when callers only need success or failure.

### 7.2 Error enum for actionable failure

```odin
Load_Error :: enum {
    None,
    Not_Found,
    Too_Large,
    Invalid_Format,
    Unsupported_Version,
}

load_asset :: proc(path: string) -> (Asset, Load_Error) {
    // ...
    return {}, .Not_Found
}
```

Keep error categories stable and meaningful to callers. Put verbose diagnostics in a separate channel rather than encoding arbitrary text into the API contract.

### 7.3 Assertions for broken invariants

```odin
assert(count <= MAX_ENTITIES)
```

Assertions are for programmer errors and impossible internal states, not routine user input failures.

### 7.4 Structured diagnostic context

```odin
Diagnostic :: struct {
    subsystem: string,
    operation: string,
    path:      string,
    code:      int,
}
```

Attach enough context to reproduce the problem while avoiding secrets and unbounded user data.

---

## 8. Testing

### 8.1 Basic unit test

```odin
package math_test

import "core:testing"

add :: proc(a, b: int) -> int {
    return a + b
}

@(test)
test_add :: proc(t: ^testing.T) {
    testing.expect_value(t, add(2, 3), 5)
}
```

Run with:

```bash
odin test .
```

### 8.2 Table-driven tests

```odin
Case :: struct {
    input:    int,
    expected: int,
}

cases := []Case{
    {0, 0},
    {1, 1},
    {2, 4},
}

for c in cases {
    testing.expect_value(t, square(c.input), c.expected)
}
```

Include boundary, invalid, and degenerate cases—not only representative happy paths.

### 8.3 Test stale handles

A handle pool should test this exact sequence:

1. create object A;
2. destroy A;
3. create object B in the reused slot;
4. verify A no longer resolves;
5. verify B resolves.

This protects the core lifetime invariant rather than just testing creation.

### 8.4 Deterministic simulation test

Feed fixed inputs and fixed `dt`, then compare a compact state snapshot or checksum after N ticks. Do not depend on wall-clock time in a deterministic unit test.

---

## 9. Concurrency

### 9.1 Prefer ownership transfer

Instead of sharing mutable state freely, transfer jobs and results through queues with clear ownership.

```odin
Job :: struct {
    kind: Job_Kind,
    payload_index: u32,
}
```

The payload storage must outlive the queued job.

### 9.2 Mutex-protected state

```odin
Shared_State :: struct {
    mutex: sync.Mutex,
    value: int,
}
```

Lock for the smallest region that preserves the invariant. Do not call unknown callbacks or blocking I/O while holding a subsystem mutex.

### 9.3 Frame jobs

A safe frame pattern is:

```text
build immutable job inputs
→ dispatch jobs
→ wait at an explicit barrier
→ merge results deterministically
→ reset frame-local storage
```

Never reset an arena while a worker may still reference it.

### 9.4 Atomics

Use atomics for narrow, well-defined state transitions such as counters, flags, and lock-free indices. Document the memory-order reasoning. A complicated shared structure is usually clearer behind a mutex or queue.

---

## 10. Data-oriented patterns

### 10.1 Structure of arrays

```odin
Particles :: struct {
    x:  []f32,
    y:  []f32,
    vx: []f32,
    vy: []f32,
}

update_positions :: proc(p: ^Particles, dt: f32) {
    for i in 0..<len(p.x) {
        p.x[i] += p.vx[i] * dt
        p.y[i] += p.vy[i] * dt
    }
}
```

Use SoA when systems process a few fields over many elements. Use AoS when operations usually need the whole record. Measure representative workloads.

### 10.2 Dense component storage

```odin
Transform_Store :: struct {
    entities:   []Entity,
    transforms: []Transform,
    sparse:     []int,
}
```

Keep the dense arrays aligned by index. Update sparse mappings when swap-removing.

### 10.3 Explicit processing pipeline

```odin
frame :: proc(app: ^App, dt: f32) {
    collect_input(&app.input)
    simulate(&app.world, dt)
    extract_render_commands(&app.world, &app.renderer)
    submit_render_commands(&app.renderer)
}
```

A visible pipeline is easier to profile, test, and parallelize than deeply nested object callbacks.

### 10.4 Double-buffered commands

Use separate write and read buffers when one phase produces commands consumed later or by another thread.

```odin
Command_Buffers :: struct {
    write: [dynamic]Command,
    read:  [dynamic]Command,
}
```

Swap only at a synchronization point.

---

## 11. Binary data and interoperability

### 11.1 Versioned binary header

```odin
File_Header :: struct {
    magic:   [4]byte,
    version: u16,
    flags:   u16,
    size:    u32,
}
```

Do not serialize the struct by blindly copying memory unless layout, alignment, padding, and endianness are all part of a controlled format. Prefer field-by-field encoding.

### 11.2 Validate before allocation

For each count or size read from binary input:

```text
validate version
validate count limit
validate multiplication overflow
validate remaining bytes
then allocate
```

Never allocate directly from an untrusted length field.

### 11.3 C API boundary

```odin
foreign import c "system:C"

foreign c {
    c_function :: proc "c" (data: rawptr, count: uintptr) -> int ---
}
```

Across ABI boundaries, prefer fixed-width scalars, opaque handles, plain structs, pointer-plus-length pairs, explicit calling conventions, and same-side allocation/free.

### 11.4 Opaque native handle

```odin
Native_Window :: distinct rawptr
```

Wrap foreign resources in a project type so the rest of the codebase does not spread raw foreign pointers.

---

## 12. Game and engine patterns

### 12.1 Fixed-step simulation

```odin
FIXED_DT :: 1.0 / 60.0

accumulator += frame_dt
for accumulator >= FIXED_DT {
    simulate(world, f32(FIXED_DT))
    accumulator -= FIXED_DT
}
```

Clamp extreme `frame_dt` values to avoid unbounded catch-up after a pause or debugger stop.

### 12.2 Input snapshot

```odin
Input :: struct {
    down:     [Key_Count]bool,
    pressed:  [Key_Count]bool,
    released: [Key_Count]bool,
}
```

Build one snapshot per frame from queued platform events. Clear transition fields at the start of the next frame.

### 12.3 Render command extraction

```odin
Draw_Command :: struct {
    mesh:      Mesh_Handle,
    material:  Material_Handle,
    transform: Mat4,
    sort_key:  u64,
}
```

Simulation owns the world; the renderer consumes a derived command stream. This prevents renderer internals from becoming gameplay state.

### 12.4 Asset state machine

```odin
Asset_State :: enum {
    Unloaded,
    Queued,
    Loading,
    Ready,
    Failed,
}
```

Keep identity stable while the loaded resource changes. Store failure diagnostics separately from the state enum.

### 12.5 Undoable editor command

```odin
Editor_Command :: struct {
    kind:   Command_Kind,
    before: Command_Data,
    after:  Command_Data,
}
```

Apply changes through commands rather than mutating editor state from arbitrary widgets. Group drag operations into one logical command.

### 12.6 Safe hot reload

Reload only when:

- plugin jobs are complete;
- callbacks cannot enter the old module;
- queues are drained or versioned;
- the new API version is validated;
- persistent state is valid or migrated.

Keep the old module active until the replacement has loaded successfully.

### 12.7 Release manifest

```odin
Build_Info :: struct {
    product_version: string,
    source_commit:   string,
    target:          string,
    asset_version:   u32,
    save_version:    u32,
}
```

Include this information in logs, diagnostics, save files, and crash reports.

---

## Recipe checklist

Before adopting a recipe, answer:

- Who owns each allocation?
- How long may returned views remain valid?
- What are the capacity and input limits?
- Is ordering stable or intentionally unstable?
- What failures are normal and how are they reported?
- Is the operation deterministic?
- Can callbacks or threads retain borrowed memory?
- Which invariant should have a test?
- What would you measure before optimizing it?

For deeper explanations, follow the corresponding chapters in [SUMMARY.md](SUMMARY.md) and the conventions in [STYLE_GUIDE.md](STYLE_GUIDE.md).
