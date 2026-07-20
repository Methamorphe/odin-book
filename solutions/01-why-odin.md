# Chapter 1 Solutions — Why Odin?

[Exercises](../exercises/01-why-odin.md) · [Read the chapter](../book/01-why-odin.md)

These solutions are models, not scripts to memorize. Design questions may have several defensible answers when their assumptions are explicit.

## 1.1 Language goals

A strong answer identifies characteristics such as:

- native execution;
- predictable data representation;
- direct operating-system or C-library integration;
- explicit memory and lifetime control;
- performance-sensitive transformations;
- a preference for a small, understandable language surface.

## 1.2 Explicitness

Explicitness means that important behavior—allocation, mutation, failure, cleanup, foreign calls or synchronization—is visible near the code that depends on it.

It is not the same as verbosity. `defer`, slices and allocator-aware context can reduce boilerplate while still keeping resource behavior observable. The aim is to avoid hidden costs, not conveniences.

## 1.3 Deliberate omissions

Possible examples:

- classes and inheritance are replaced by structs, procedures and composition;
- exceptions are replaced by explicit results, multiple returns and error-handling helpers;
- destructors are commonly replaced by scoped cleanup with `defer`;
- a traditional method-centric object model is replaced by package-level procedures;
- pervasive runtime reflection is replaced by simpler compile-time and type-information facilities.

## 1.4 Three dimensions

**Language safety** is about invalid operations prevented by language or runtime rules. Example: an out-of-bounds slice access detected by a bounds check.

**Program correctness** is about matching intended behavior. Example: calculating tax with the wrong percentage despite using valid memory.

**Engineering reliability** concerns behavior under real operating conditions. Example: retrying a non-idempotent payment request and charging twice.

The categories overlap, but none subsumes the others.

## 1.5 Data-oriented design

A useful completion is:

> Data-oriented design begins by asking what data the program transforms, how it is accessed, and which layout best supports those transformations.

## 1.6 Choosing a language

1. **Cross-platform level editor:** strong or possible candidate. Native UI, graphics, file processing and a C physics library align with Odin's strengths. UI-library maturity and platform support must be checked.
2. **Internal invoicing web app:** usually weak candidate. Framework ecosystem, authentication, database tooling and hiring likely matter more than low-level control.
3. **Audio plugin:** strong candidate. Deterministic performance, native ABI integration and allocation control are valuable.
4. **Safety-certified train control:** weak unless the certification environment explicitly supports Odin. Language choice is dominated by standards, evidence and qualified tooling.
5. **Texture conversion CLI:** strong candidate when native image libraries and high-throughput processing matter; merely possible if an existing Python tool already meets every requirement.

## 1.7 Visible costs

The original API leaves ownership ambiguous. Callers cannot know whether they must free the buffer, which allocator created it, whether it can outlive the decoder, or whether it aliases internal storage.

A clearer contract could state:

- the caller owns the returned buffer;
- allocation uses an allocator supplied by the caller;
- release occurs through the same allocator or a named release procedure;
- the buffer remains valid until explicitly released;
- failure returns no owned buffer.

Another valid design is for the caller to provide destination storage.

## 1.8 Foreign boundaries

Problems include duplicated error translation, inconsistent cleanup, foreign types leaking across the application, repeated unsafe conversions, difficult library upgrades and inconsistent thread-safety assumptions.

A better design places direct C calls in one package. That package owns translation between C and Odin types, documents lifetime rules, normalizes errors and exposes a narrow native API.

## 1.9 Object-first versus data-first

A data-oriented alternative might store contiguous arrays for positions, velocities and colors, then update them in batches with ordinary procedures. Dynamic dispatch can be removed if all particles share the same operation, or replaced by grouping particles by behavior.

Measurements should include frame time, update time, cache misses where available, memory footprint, allocation count, branch behavior and implementation complexity. A representative workload is essential.

## 1.10 Assertions and expected failure

1. Missing user file: expected failure.
2. Mismatched internal arrays: violated invariant, usually an assertion in development plus architectural prevention.
3. Network timeout: expected failure.
4. Invalid trusted internal enum: violated invariant.
5. Missing graphics device: expected environmental failure.

Expected failures should be represented and propagated in normal control flow. Violated invariants should be prevented by design and detected loudly during development.

## 1.11 Lifetime strategy

A temporary arena is the strongest default. All parse-time allocations share the load operation's lifetime and can be discarded together after the final representation is built.

Benefits include simple cleanup, low allocator overhead and clear lifetime reasoning. Risks include accidentally storing pointers into the temporary arena inside the persistent level. The required invariant is that every surviving value either owns persistent storage or refers only to data with a sufficiently long lifetime.

## 1.12 Small native tool

A good answer is specific. For an image converter, for example:

- input: encoded image bytes and conversion options;
- transformations: decode, resize, colorspace conversion, encode;
- output: a new image file and diagnostics;
- failures: unreadable input, unsupported format, allocation failure, invalid dimensions, write failure;
- boundaries: filesystem and image-codec library;
- lifetimes: temporary decode arena plus output buffer lifetime;
- measurements: throughput, peak memory, allocation count and output quality;
- language fit: strong when native codec integration and throughput matter.

## 1.13 Architecture critique

The rule creates indirection, larger values, weaker optimization opportunities and a uniform abstraction before variation is demonstrated.

Dynamic dispatch is justified when behavior must vary at runtime across independently implemented components, plugins or platform backends. It is unnecessary when a closed set of behaviors can use a tagged union, when ordinary procedures are selected statically, or when data can be grouped and processed by type.

## 1.14 Batch transformation

One valid solution:

```odin
package main

import "core:fmt"

Temperature_Sample :: struct {
    celsius: f32,
}

celsius_to_fahrenheit :: proc(celsius: f32) -> f32 {
    return celsius * 9.0 / 5.0 + 32.0
}

main :: proc() {
    samples := []Temperature_Sample {
        {celsius = 12.5},
        {celsius = 18.0},
        {celsius = 21.5},
        {celsius = 24.0},
        {celsius = 27.5},
    }

    sum: f32
    for sample in samples {
        fmt.printf("%.1f C = %.1f F\n", sample.celsius, celsius_to_fahrenheit(sample.celsius))
        sum += sample.celsius
    }

    average := sum / f32(len(samples))
    fmt.printf("Average: %.1f C\n", average)
}
```

The literal slice in this small example does not require the programmer to request a dynamic allocation. `celsius_to_fahrenheit` receives an `f32` by value, and the range loop's `sample` is also a value. If each sample contained a large payload, options would include iterating by index, passing a pointer, or separating frequently processed fields into a more appropriate layout. The right choice should follow actual access patterns.

---

[Exercises](../exercises/01-why-odin.md) · [Read the chapter](../book/01-why-odin.md)