# Chapter 11 Solutions — Structs, Enums, and Unions

[← Exercises](../exercises/11-structs-enums-unions.md) · [Chapter](../book/11-structs-enums-unions.md)

```odin
Rectangle :: struct { width, height: f32 }
area :: proc(r: Rectangle) -> f32 { return r.width * r.height }
perimeter :: proc(r: Rectangle) -> f32 { return 2 * (r.width + r.height) }
```

```odin
Traffic_Light :: enum { Red, Green, Amber }
next :: proc(v: Traffic_Light) -> Traffic_Light {
    switch v {
    case .Red: return .Green
    case .Green: return .Amber
    case .Amber: return .Red
    }
    unreachable()
}
```

```odin
Permission :: enum { Read, Write, Execute }
Permissions :: bit_set[Permission]
```

A union state removes invalid combinations:

```odin
Loading :: struct { progress: f32 }
Ready :: struct { resource_id: u64 }
Failed :: struct { message: string }
Asset_State :: union { Loading, Ready, Failed }
```

For layout work, compare `size_of`, `align_of`, and field offsets. Padding typically appears before fields requiring stronger alignment. The event challenge should use a struct for shared metadata and a union for mutually exclusive payloads.
