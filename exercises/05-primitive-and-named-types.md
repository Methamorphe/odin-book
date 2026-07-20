# Chapter 5 Exercises — Primitive and Named Types

[← Back to Chapter 5](../book/05-primitive-and-named-types.md) · [Solutions](../solutions/05-primitive-and-named-types.md)

## Exercise 5.1 — Choose the representation

Choose and justify a type for each value:

1. a local loop index;
2. a packet sequence number stored as 32 bits;
3. a texture width sent to a graphics API expecting an unsigned 32-bit integer;
4. elapsed wall-clock seconds requiring high precision;
5. one raw byte from a file;
6. a Unicode code point.

## Exercise 5.2 — Literal notation

Write the value 255 in decimal, binary, octal, and hexadecimal notation. Use underscores to make a 32-bit bitmask readable.

## Exercise 5.3 — Explicit conversion

Convert a `u32` item count to `f32` and calculate a percentage. Then convert a runtime `u32` to `u8` only after checking that it fits.

## Exercise 5.4 — Alias versus distinct type

Create:

```odin
User_Index :: int
User_ID :: distinct u64
Order_ID :: distinct u64
```

Demonstrate which assignments compile and which do not. Explain why the alias provides vocabulary but not separation.

## Exercise 5.5 — Units

Define distinct types for `Meters`, `Seconds`, and `Meters_Per_Second`. Write a procedure that calculates speed and returns the correctly named type.

## Exercise 5.6 — Strongly typed handles

Define distinct `Texture_Handle`, `Mesh_Handle`, and `Audio_Handle` types over `u32`. Write one procedure for each handle and prove that a handle cannot be passed to the wrong procedure.

## Exercise 5.7 — UTF-8 reasoning

Create strings containing ASCII, accented Latin text, and emoji. Compare `len` results with the number of characters a user perceives. Explain why byte length is not a character count.

## Exercise 5.8 — Overflow-aware allocation math

Given `width: u32`, `height: u32`, and `bytes_per_pixel: u64`, compute a byte count using a wider intermediate representation. Add reasonable upper-bound checks before the calculation would be used for allocation.

## Challenge — Domain model

Model a small telemetry system using distinct types for `Sensor_ID`, `Timestamp_MS`, `Temperature_Celsius`, and `Humidity_Percent`. Write procedures that accept only the correct types, perform explicit conversions at input boundaries, and print a validated sample.
