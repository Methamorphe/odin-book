# Chapter 13 — `defer`, Cleanup, and Explicit Errors

[← Chapter 12: Pointers and Addressability](12-pointers-addressability.md) · [Exercises](../exercises/13-defer-explicit-errors.md) · [Chapter 14: The Odin Memory Model →](14-memory-model.md)

Systems programs acquire resources that must be released: files, allocations, sockets, locks, temporary buffers, and foreign handles. Odin combines explicit results with `defer` so cleanup remains visible and reliable.

## 13.1 `defer`

A deferred statement runs when the surrounding scope exits:

```odin
file, ok := os.open("data.txt")
if !ok { return }
defer os.close(file)
```

Place cleanup immediately after successful acquisition. This keeps ownership and release together.

## 13.2 LIFO ordering

Deferred operations run in reverse order:

```odin
defer fmt.println("first")
defer fmt.println("second")
// prints second, then first
```

This naturally mirrors nested acquisition.

## 13.3 Scope matters

A `defer` belongs to its lexical scope, not merely the function. A defer inside a loop may accumulate until the enclosing scope exits. Introduce a smaller scope or helper procedure when each iteration must release promptly.

## 13.4 Multiple return values for errors

Odin APIs commonly return a value and a status:

```odin
value, ok := parse_int(text)
if !ok {
    fmt.eprintln("invalid integer")
    return
}
```

The caller must decide how to handle failure. There are no hidden exceptions unwinding arbitrary frames.

## 13.5 Enumerated errors

For richer failures, define an enum:

```odin
Parse_Error :: enum {
    None,
    Empty,
    Invalid_Character,
    Overflow,
}

parse :: proc(text: string) -> (int, Parse_Error)
```

Use errors that help the caller make a decision. Avoid encoding implementation details that callers cannot act upon.

## 13.6 Result unions

A union can represent either success or failure when payloads differ:

```odin
Failure :: struct { message: string }
Load_Result :: union { Asset, Failure }
```

This is useful at subsystem boundaries, especially when the success and failure states carry structured data.

## 13.7 Propagation helpers

Odin provides helpers such as `or_return` for suitable multi-value results. Use them when propagation is truly mechanical. Expand the control flow when adding context, translating errors, logging, or cleanup decisions.

The goal is not minimal line count; it is visible failure policy.

## 13.8 Cleanup on every exit

`defer` runs for early returns from the scope:

```odin
buffer := make([]byte, 4096)
defer delete(buffer)

if invalid_input {
    return
}
```

This prevents duplicated cleanup branches.

## 13.9 Ownership transfer

Do not defer destruction when ownership is transferred to the caller. Make the transfer obvious:

```odin
make_buffer :: proc() -> ([]byte, bool) {
    data := make([]byte, 1024)
    if data == nil { return nil, false }
    return data, true // caller owns data
}
```

Document who releases returned resources.

## 13.10 Partial initialization

Constructors can fail after acquiring several resources. Defer each cleanup as soon as acquisition succeeds, then cancel or bypass those defers only when ownership is safely transferred. Alternatively, build through a temporary owner object whose destructor handles partial state.

## 13.11 Error context

Low-level errors should be translated at subsystem boundaries:

```text
OS permission denied
→ asset file could not be opened
→ level "intro" failed to load
```

Add context without logging the same failure at every layer. Decide which layer owns user-facing reporting.

## 13.12 Panic, assertions, and recoverable errors

Use recoverable results for expected environmental failures: missing files, invalid input, disconnected peers, or unavailable devices.

Use assertions for violated programmer assumptions and internal invariants. Do not convert every bug into a runtime error path that silently continues.

## 13.13 Transactions and rollback

`defer` can express rollback:

```odin
committed := false
defer if !committed { rollback(&transaction) }

// perform operations
commit(&transaction)
committed = true
```

This pattern is useful for parsers, file replacement, database-like state changes, and initialization sequences.

## 13.14 Worked example

```odin
copy_file :: proc(source_path, destination_path: string) -> bool {
    source, source_ok := os.open(source_path)
    if !source_ok { return false }
    defer os.close(source)

    destination, destination_ok := os.create(destination_path)
    if !destination_ok { return false }
    defer os.close(destination)

    // Copy loop omitted here.
    return true
}
```

Each successful acquisition has one nearby release.

## 13.15 Common mistakes

- placing `defer` before checking acquisition success;
- deferring per-iteration cleanup in a long-running loop scope;
- logging and re-logging the same error at every layer;
- returning borrowed data after its owner is destroyed;
- using panic for ordinary invalid user input;
- hiding ownership transfer.

## 13.16 Part I review

Part I introduced the language foundations needed for real Odin programs: declarations, types, procedures, control flow, packages, collections, text, aggregate types, pointers, cleanup, and errors.

Part II now shifts from syntax to deliberate storage and lifetime design.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)
- [Odin package documentation](https://pkg.odin-lang.org/)
