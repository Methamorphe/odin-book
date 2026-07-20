# Chapter 4 Exercises — Values, Variables and Constants

[← Back to Chapter 4](../book/04-values-variables-constants.md) · [Solutions](../solutions/04-values-variables-constants.md)

## Exercise 4.1 — Classify declarations

For each declaration, state whether it introduces runtime storage or a compile-time-known entity:

```odin
count := 10
Limit :: 10
ratio: f32 = 0.5
Name: string : "Odin"
add :: proc(a, b: int) -> int { return a + b }
```

## Exercise 4.2 — Expand shorthand

Rewrite these declarations in their most explicit equivalent form:

```odin
score := 120
Enabled :: true
width: = 1920
```

Then reduce these declarations to idiomatic shorthand where no information is lost:

```odin
height: int = 1080
Title: string : "Sandbox"
```

## Exercise 4.3 — Swap and rotate

Declare three integers and rotate their values using one multiple assignment. For initial values `1, 2, 3`, the final values must be `3, 1, 2`.

## Exercise 4.4 — Zero values

Declare uninitialized variables of types `int`, `bool`, `f32`, and `^int`. Print or assert their zero values. Explain why zero initialization does not guarantee semantic validity.

## Exercise 4.5 — Scope and shadowing

Write a nested scope that shadows a variable. Print the inner and outer values. Then rewrite the example without shadowing and explain which version is easier to maintain.

## Exercise 4.6 — Compile-time configuration

Define compile-time constants for:

- bytes per kilobyte;
- bytes per megabyte;
- a 16 MiB asset budget;
- a target frame rate of 120;
- the corresponding frame budget in nanoseconds.

Print the final computed values from `main`.

## Exercise 4.7 — Addressability experiment

Take the address of a runtime variable. Then investigate what happens when you try to take the address of a plain `::` constant. Describe the difference in your own words.

## Challenge — Runtime state versus program definition

Model a download worker with compile-time limits and runtime state. Include constants for maximum retries and chunk size, plus variables for current retry count, downloaded bytes, and connection status. Use explicit types where binary width or meaning matters.
