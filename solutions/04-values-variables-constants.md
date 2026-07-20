# Chapter 4 Solutions — Values, Variables and Constants

[← Exercises](../exercises/04-values-variables-constants.md) · [Back to Chapter 4](../book/04-values-variables-constants.md)

## Solution 4.1

- `count := 10`: runtime variable with inferred type.
- `Limit :: 10`: compile-time constant declaration.
- `ratio: f32 = 0.5`: runtime variable with explicit type.
- `Name: string : "Odin"`: typed compile-time constant.
- `add :: proc(...)`: compile-time-known procedure declaration.

## Solution 4.2

Expanded:

```odin
score: int = 120
Enabled: bool : true
width: int = 1920
```

Idiomatic shorthand:

```odin
height := 1080
Title :: "Sandbox"
```

Keeping `height: int = 1080` would also be reasonable when the explicit type communicates an API or representation requirement.

## Solution 4.3

```odin
a, b, c := 1, 2, 3
a, b, c = c, a, b
```

## Solution 4.4

```odin
count: int
active: bool
ratio: f32
pointer: ^int

assert(count == 0)
assert(active == false)
assert(ratio == 0)
assert(pointer == nil)
```

A zeroed value can still violate a domain rule. For example, zero may be an invalid database identifier or an unopened resource handle.

## Solution 4.5

Shadowed names are legal in nested scopes but can hide which storage is being read or changed. A rewritten version with names such as `outer_count` and `inner_count` is usually clearer when both values matter simultaneously.

## Solution 4.6

```odin
Bytes_Per_Kilobyte :: 1024
Bytes_Per_Megabyte :: 1024 * Bytes_Per_Kilobyte
Asset_Budget       :: 16 * Bytes_Per_Megabyte
Target_FPS         :: 120
Nanoseconds_Per_Second :: 1_000_000_000
Frame_Budget_NS    :: Nanoseconds_Per_Second / Target_FPS
```

## Solution 4.7

```odin
value := 42
pointer := &value
```

A runtime variable has addressable storage. A plain compile-time constant is a compile-time-known entity and should not be treated as an object with stable runtime storage.

## Challenge solution

```odin
package main

import "core:fmt"

Max_Retries :: 5
Chunk_Size_Bytes :: 64 * 1024

main :: proc() {
    retry_count: u8 = 0
    downloaded_bytes: u64 = 0
    connected := false

    fmt.println(Max_Retries, Chunk_Size_Bytes)
    fmt.println(retry_count, downloaded_bytes, connected)
}
```

The constants define the worker policy. The variables represent state that changes while the program runs.
