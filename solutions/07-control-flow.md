# Chapter 7 Solutions — Control Flow

[← Exercises](../exercises/07-control-flow.md) · [Chapter →](../book/07-control-flow.md)

## 1. Temperature classification

```odin
if temperature < 0 {
    state = "freezing"
} else if temperature < 20 {
    state = "cold"
} else {
    state = "warm"
}
```

## 2. Guard clauses

Return immediately for empty input, missing resources, and unsupported formats. Keep the valid path unindented.

## 3. Command router

```odin
switch command {
case "start": start()
case "stop": stop()
case "status": status()
case: fmt.println("unknown command")
}
```

## 4. Condition switch

```odin
switch {
case health <= 0: state = .Dead
case health < 25: state = .Critical
case health < 75: state = .Wounded
case: state = .Healthy
}
```

## 5. Positive sum

```odin
total := 0
for value in values {
    if value <= 0 { continue }
    total += value
}
```

## 6. Labeled break

Use `outer:` on the row loop and `break outer` after finding the target.

## 7. Write cursor

```odin
write := 0
for value in values {
    if value >= 0 {
        values[write] = value
        write += 1
    }
}
values = values[:write]
```

## 8. Running maximum invariant

Before each iteration, the stored maximum equals the largest value among elements already visited.

## 9. Duplicate search

A nested scan is generally quadratic. A map-backed seen set is generally linear on average, at the cost of allocation and hashing.

## 10. State machine

Represent states and events with enums. Put transitions in one switch and reject or ignore invalid transitions explicitly. Keep side effects separate from transition calculation as the machine grows.
