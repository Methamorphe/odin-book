# Chapter 11 — Structs, Enums, and Unions

[← Chapter 10: Maps, Strings and Runes](10-maps-strings-runes.md) · [Exercises](../exercises/11-structs-enums-unions.md) · [Chapter 12: Pointers and Addressability →](12-pointers-addressability.md)

Odin's aggregate types let programs describe domain data directly. Structs group fields, enums define a finite set of named values, and unions model values that may have one of several representations.

## 11.1 Structs

A struct groups related values into one type:

```odin
Vec2 :: struct {
    x: f32,
    y: f32,
}

position := Vec2{x = 12, y = 4}
```

Prefer field names in literals. Positional literals are shorter, but become fragile when fields are reordered or added.

## 11.2 Zero values

Every field has a zero value when omitted:

```odin
Player :: struct {
    health: int,
    active: bool,
}

player: Player // health == 0, active == false
```

Zero initialization is useful, but a zero value is not automatically a valid domain value. Provide constructors or validation when invariants matter.

## 11.3 Struct procedures

Odin does not require methods to live inside a type. Procedures remain ordinary package declarations:

```odin
length_squared :: proc(v: Vec2) -> f32 {
    return v.x*v.x + v.y*v.y
}
```

This keeps data and behavior independently composable.

## 11.4 Value semantics

Struct assignment copies the value:

```odin
a := Vec2{x = 1, y = 2}
b := a
b.x = 99
// a.x is still 1
```

For large values or mutation, pass a pointer deliberately.

## 11.5 Struct layout

Field order affects alignment, padding, and total size. Keep layout-sensitive types explicit when interoperating with C, binary files, GPU buffers, or network protocols. Do not assume that two structs with the same fields in a different order share a representation.

Use `size_of`, `align_of`, and `offset_of` when verifying an ABI or serialized layout.

## 11.6 Enums

Enums define a closed set of named values:

```odin
Direction :: enum {
    North,
    East,
    South,
    West,
}
```

They work well with exhaustive `switch` statements:

```odin
turn_right :: proc(direction: Direction) -> Direction {
    switch direction {
    case .North: return .East
    case .East:  return .South
    case .South: return .West
    case .West:  return .North
    }
    unreachable()
}
```

Enums communicate meaning better than integer constants and prevent unrelated values from mixing.

## 11.7 Explicit enum values

External protocols may require stable numeric values:

```odin
Http_Status :: enum u16 {
    Ok = 200,
    Not_Found = 404,
    Server_Error = 500,
}
```

Choose an explicit backing type only when representation matters.

## 11.8 Enum arrays

An enum can index fixed-size tables when its values are dense and controlled:

```odin
Weapon :: enum { Sword, Bow, Staff }
Damage_Table :: [Weapon]int{10, 7, 14}
```

This is compact and fast, but it assumes enum values form a suitable index domain.

## 11.9 Unions

A union allows the same storage to hold one of several types:

```odin
Value :: union {
    int,
    f64,
    string,
}
```

A union value carries enough information for type-safe inspection:

```odin
print_value :: proc(value: Value) {
    switch v in value {
    case int:    fmt.println("int", v)
    case f64:    fmt.println("float", v)
    case string: fmt.println("string", v)
    }
}
```

This is useful for parsers, event payloads, editor properties, and heterogeneous data.

## 11.10 Tagged domain states

Unions are strongest when each alternative is meaningful:

```odin
Loading :: struct { progress: f32 }
Ready   :: struct { resource_id: u64 }
Failed  :: struct { message: string }

Asset_State :: union { Loading, Ready, Failed }
```

Compared with a struct containing many optional fields, the union makes impossible combinations unrepresentable.

## 11.11 `union #no_nil`

A normal union may include an empty state. When the domain requires exactly one alternative, a no-nil union can express that invariant. Use it only when initialization and lifetime guarantee a valid member.

## 11.12 Bit sets

For combinations of enum flags, Odin's bit sets are clearer than manually maintained integer masks:

```odin
Permission :: enum { Read, Write, Execute }
Permissions :: bit_set[Permission]

access := Permissions{.Read, .Write}
```

Use enums for one choice and bit sets for any combination of choices.

## 11.13 Worked example: event model

```odin
Event_Kind :: enum { Connected, Disconnected, Message }

Connected :: struct { user_id: u64 }
Disconnected :: struct { user_id: u64, reason: string }
Message :: struct { user_id: u64, text: string }

Event_Data :: union { Connected, Disconnected, Message }

Event :: struct {
    sequence: u64,
    data: Event_Data,
}
```

The outer struct stores metadata common to every event while the union stores mutually exclusive payloads.

## 11.14 Design guidance

Use:

- a struct when values belong together;
- an enum when one value must come from a finite set;
- a bit set when multiple enum flags may coexist;
- a union when exactly one of several representations is active.

Avoid giant structs filled with booleans and nullable fields when the real domain is a state machine.

## 11.15 Common mistakes

- depending on positional struct literals across package boundaries;
- assuming zero initialization satisfies domain invariants;
- storing protocol values in enums without fixing their representation;
- replacing a union with `rawptr` and a manual tag;
- ignoring padding in layout-sensitive data.

## 11.16 Chapter checklist

You should now be able to model records with structs, closed choices with enums, flag combinations with bit sets, and variant payloads with unions.

## References

- [Odin overview: aggregate types](https://odin-lang.org/docs/overview/)
- [Odin package documentation](https://pkg.odin-lang.org/)
