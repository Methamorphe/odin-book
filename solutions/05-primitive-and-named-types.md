# Chapter 5 Solutions — Primitive and Named Types

[← Exercises](../exercises/05-primitive-and-named-types.md) · [Back to Chapter 5](../book/05-primitive-and-named-types.md)

## Solution 5.1

1. `int` for an ordinary local loop index.
2. `u32` because the protocol defines a 32-bit unsigned representation.
3. `u32` to match the foreign API boundary.
4. Usually `f64`, subject to the clock API and precision requirements.
5. `byte` or `u8` for raw octets.
6. `rune` for a Unicode code point.

## Solution 5.2

```odin
decimal := 255
binary  := 0b1111_1111
octal   := 0o377
hex     := 0xff
mask    := 0b1111_0000_1010_0101_1100_0011_0011_1100
```

## Solution 5.3

```odin
count: u32 = 75
percentage := f32(count) / 100.0 * 100.0

source: u32 = 200
if source <= 255 {
    narrowed := u8(source)
    _ = narrowed
}
```

The range check must happen before narrowing runtime data.

## Solution 5.4

```odin
User_Index :: int
User_ID :: distinct u64
Order_ID :: distinct u64

index: User_Index = 3
plain: int = index // alias: same type

user := User_ID(42)
order := Order_ID(42)
// user = order // rejected
```

An alias changes vocabulary. A distinct declaration creates a separate type.

## Solution 5.5

```odin
Meters :: distinct f32
Seconds :: distinct f32
Meters_Per_Second :: distinct f32

speed :: proc(distance: Meters, duration: Seconds) -> Meters_Per_Second {
    return Meters_Per_Second(f32(distance) / f32(duration))
}
```

Production code should also reject a zero or invalid duration.

## Solution 5.6

```odin
Texture_Handle :: distinct u32
Mesh_Handle :: distinct u32
Audio_Handle :: distinct u32

use_texture :: proc(value: Texture_Handle) {}
use_mesh :: proc(value: Mesh_Handle) {}
use_audio :: proc(value: Audio_Handle) {}
```

Passing `Mesh_Handle(1)` to `use_texture` is rejected because the types are distinct even though their storage is identical.

## Solution 5.7

UTF-8 uses a variable number of bytes per code point. ASCII characters occupy one byte, accented characters often occupy more, and emoji may use several code points and bytes. Therefore `len(string)` is a byte count, not a count of code points or user-perceived grapheme clusters.

## Solution 5.8

```odin
width: u32 = 1920
height: u32 = 1080
bytes_per_pixel: u64 = 4

Max_Dimension :: 16_384

if width > 0 && height > 0 &&
   width <= Max_Dimension && height <= Max_Dimension {
    pixel_count := u64(width) * u64(height)
    byte_count := pixel_count * bytes_per_pixel
    _ = byte_count
}
```

A real allocator boundary should also compare `byte_count` with the application's memory budget and the maximum representable allocation size.

## Challenge solution

```odin
package main

import "core:fmt"

Sensor_ID :: distinct u32
Timestamp_MS :: distinct u64
Temperature_Celsius :: distinct f32
Humidity_Percent :: distinct f32

Sample :: struct {
    sensor: Sensor_ID,
    timestamp: Timestamp_MS,
    temperature: Temperature_Celsius,
    humidity: Humidity_Percent,
}

print_sample :: proc(sample: Sample) {
    fmt.printf(
        "sensor=%d timestamp=%d temperature=%.2f C humidity=%.1f%%\n",
        u32(sample.sensor),
        u64(sample.timestamp),
        f32(sample.temperature),
        f32(sample.humidity),
    )
}

main :: proc() {
    raw_humidity: f32 = 48.5
    if raw_humidity < 0 || raw_humidity > 100 {
        return
    }

    sample := Sample{
        sensor = Sensor_ID(7),
        timestamp = Timestamp_MS(1_725_000_000_000),
        temperature = Temperature_Celsius(21.75),
        humidity = Humidity_Percent(raw_humidity),
    }

    print_sample(sample)
}
```
