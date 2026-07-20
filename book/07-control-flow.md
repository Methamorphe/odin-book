# Chapter 7 — Control Flow

[← Chapter 6: Procedures](06-procedures.md) · [Exercises](../exercises/07-control-flow.md) · [Chapter 8: Packages and Project Organization →](08-packages.md)

Control flow determines which operations run, how often they run, and where execution continues. Odin keeps these mechanisms small and explicit: `if`, `switch`, `for`, `break`, `continue`, and `return` cover most programs without a collection of overlapping loop constructs.

## 7.1 Conditions are boolean

```odin
if temperature < 0 {
    fmt.println("freezing")
}
```

Odin does not treat integers, pointers, or strings as truth values. State the condition explicitly:

```odin
if count > 0 { /* ... */ }
if pointer != nil { /* ... */ }
if len(name) != 0 { /* ... */ }
```

This makes intent visible and avoids accidental truthiness.

## 7.2 `if`, `else if`, and `else`

```odin
if score >= 90 {
    grade = "A"
} else if score >= 75 {
    grade = "B"
} else {
    grade = "C"
}
```

Order matters: the first matching branch runs. Arrange conditions from exceptional or most specific to general.

An `if` statement can include an initializer whose scope is limited to the conditional:

```odin
if value, ok := parse_number(text); ok {
    fmt.println(value)
} else {
    fmt.println("invalid number")
}
```

This keeps temporary state near the decision that uses it.

## 7.3 Prefer guard clauses

Deep nesting hides the main path:

```odin
load_asset :: proc(path: string) -> bool {
    if len(path) > 0 {
        if file_exists(path) {
            if supported(path) {
                return decode(path)
            }
        }
    }
    return false
}
```

Guard clauses are clearer:

```odin
load_asset :: proc(path: string) -> bool {
    if len(path) == 0 { return false }
    if !file_exists(path) { return false }
    if !supported(path) { return false }
    return decode(path)
}
```

## 7.4 Basic `switch`

```odin
switch command {
case "start":
    start_server()
case "stop":
    stop_server()
case "status":
    print_status()
case:
    fmt.println("unknown command")
}
```

The empty `case:` is the default branch. Cases do not fall through implicitly. This prevents a common C-family error.

Multiple values can share a case:

```odin
switch extension {
case ".jpg", ".jpeg", ".png":
    load_image()
case ".wav", ".ogg":
    load_audio()
}
```

## 7.5 Condition switches

A switch can omit the subject and act as an ordered condition list:

```odin
switch {
case health <= 0:
    state = .Dead
case health < 25:
    state = .Critical
case health < 75:
    state = .Wounded
case:
    state = .Healthy
}
```

This is useful when branches depend on ranges or unrelated predicates.

## 7.6 Type switches

Odin's type-system features allow branching on runtime type information in appropriate contexts. Keep type switches at integration or reflection boundaries. If ordinary domain behavior constantly requires checking concrete types, the data model may be too indirect.

## 7.7 The universal `for` loop

Odin uses `for` for all looping forms.

Classic counter loop:

```odin
for i := 0; i < 10; i += 1 {
    fmt.println(i)
}
```

Condition-only loop:

```odin
for queue_has_work() {
    process_next()
}
```

Infinite loop:

```odin
for {
    tick()
}
```

The absence of separate `while` and `do while` syntax reduces conceptual surface area.

## 7.8 Range iteration

Iterate values and indexes with `in`:

```odin
scores := []int{10, 20, 30}
for score, index in scores {
    fmt.printf("%d: %d\n", index, score)
}
```

Ignore what you do not need:

```odin
for score in scores {
    total += score
}

for _, index in scores {
    fmt.println(index)
}
```

Be precise about value versus address. Iteration variables may be copies depending on the collection and form. When mutation of elements is required, use indexing or an explicit pointer-oriented form that makes the write target clear.

## 7.9 `break` and `continue`

`break` exits the nearest loop. `continue` skips to its next iteration:

```odin
for value in values {
    if value < 0 {
        continue
    }
    if value == target {
        found = true
        break
    }
    process(value)
}
```

Use them to keep the normal path flat, but avoid loops with so many exits that their invariants become difficult to understand.

## 7.10 Labeled control flow

Nested loops sometimes need an explicit target:

```odin
outer: for row in grid {
    for cell in row {
        if cell == target {
            break outer
        }
    }
}
```

Labels are clearer than auxiliary booleans when escaping a specific nested construct. Keep labels descriptive in nontrivial code.

## 7.11 `defer` and control flow

`defer` schedules work for the end of the current scope:

```odin
file, ok := os.open(path)
if !ok { return false }
defer os.close(file)
```

Cleanup remains adjacent to acquisition while running regardless of which later return path is taken. Chapter 13 covers `defer` and error propagation in depth.

## 7.12 Loop invariants

A loop is easier to reason about when you can state what remains true before and after each iteration. Consider summing positive values:

```odin
total := 0
for value in values {
    if value <= 0 { continue }
    total += value
}
```

Invariant: before each iteration, `total` equals the sum of positive values already visited. Thinking this way exposes initialization and boundary mistakes.

## 7.13 Avoid accidental quadratic work

Nested loops are not inherently wrong, but their cost matters:

```odin
for a in items {
    for b in items {
        compare(a, b)
    }
}
```

For `n` items, this performs roughly `n²` comparisons. Sometimes that is required; sometimes a map, sorted pass, spatial index, or preprocessing step is better. Control flow is also performance architecture.

## 7.14 State machines

Enums and switches make small state machines explicit:

```odin
Connection_State :: enum { Disconnected, Connecting, Connected, Failed }

update :: proc(state: ^Connection_State, event: Event) {
    switch state^ {
    case .Disconnected:
        if event == .Connect { state^ = .Connecting }
    case .Connecting:
        if event == .Success { state^ = .Connected }
        else if event == .Failure { state^ = .Failed }
    case .Connected:
        if event == .Disconnect { state^ = .Disconnected }
    case .Failed:
        if event == .Retry { state^ = .Connecting }
    }
}
```

For larger systems, separate transition calculation from side effects and validate impossible transitions.

## 7.15 Common mistakes

### Complex boolean expressions

Break a dense condition into named intermediate values when the names communicate policy.

### Mutation hidden in conditions

A condition that performs substantial work or changes global state is difficult to reason about. Keep decisions and effects visibly separate.

### Off-by-one loops

Prefer half-open ranges and explicit collection lengths. Test empty, one-element, and boundary-sized inputs.

### Modifying a collection while iterating it

Removal may invalidate indexes or skip elements. Use reverse iteration, a write cursor, deferred removals, or a filtered destination.

## 7.16 Worked example: command processor

```odin
package main

import "core:fmt"

main :: proc() {
    commands := []string{"status", "start", "status", "stop"}
    running := false

    for command, index in commands {
        fmt.printf("[%d] %s: ", index, command)

        switch command {
        case "start":
            if running {
                fmt.println("already running")
                continue
            }
            running = true
            fmt.println("started")
        case "stop":
            if !running {
                fmt.println("already stopped")
                continue
            }
            running = false
            fmt.println("stopped")
        case "status":
            fmt.println(running ? "running" : "stopped")
        case:
            fmt.println("unknown")
        }
    }
}
```

## Chapter summary

- Conditions require explicit booleans.
- Guard clauses keep valid paths flat.
- `switch` handles values, conditions, and grouped cases without implicit fallthrough.
- One `for` construct covers counters, conditions, ranges, and infinite loops.
- `break`, `continue`, labels, and `return` should make flow clearer, not more fragmented.
- Loop invariants and complexity analysis are part of correct systems programming.

## References

- [Odin overview](https://odin-lang.org/docs/overview/)

[Exercises →](../exercises/07-control-flow.md) · [Next chapter →](08-packages.md)
