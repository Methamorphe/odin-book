# Chapter 13 Solutions — Cleanup and Explicit Errors

[← Exercises](../exercises/13-defer-explicit-errors.md) · [Chapter](../book/13-defer-explicit-errors.md)

Acquire each resource, check success, and immediately register its cleanup:

```odin
first, ok := acquire_first()
if !ok { return false }
defer release_first(first)

second, ok := acquire_second()
if !ok { return false }
defer release_second(second)
```

A useful parse error set is `None`, `Empty`, `Invalid_Character`, and `Overflow`. It lets callers distinguish malformed text from a representational limit.

A loop-scoped acquisition should be moved into a helper procedure or an explicit nested scope so cleanup occurs each iteration rather than at function exit.

For partial initialization, defer rollback after each successful acquisition and mark ownership as transferred only after the final object is valid. Missing files and invalid user values are recoverable; broken invariants and impossible states should be assertions or fatal diagnostics.
