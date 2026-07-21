# Chapter 25 — SIMD and Numerical Code

[← Chapter 24: Threads, Atomics, and Synchronization](24-threads-atomics-synchronization.md) · [Exercises](../exercises/25-simd-numerical-code.md) · [Chapter 26: Reflection and Compile-Time Features →](26-reflection-compile-time.md)

Numerical performance depends on algorithms, memory layout, precision, and vectorization. SIMD—single instruction, multiple data—lets one instruction process several lanes at once, but it only helps when data and control flow cooperate.

## 25.1 Optimize the model first

Before vectorizing, ask whether the algorithm performs unnecessary work. Improving complexity or removing allocations usually beats hand-written SIMD. Establish a scalar reference implementation and benchmark before changing representation.

## 25.2 Numeric representations

Choose representation by domain:

- `f32` for many graphics, audio, and simulation arrays;
- `f64` for greater dynamic range or accumulated precision;
- fixed-width integers for exact protocols and packed data;
- wider accumulators when sums can overflow or lose precision.

Changing from `f64` to `f32` doubles lane density on many vector units, but it also changes numerical behavior. Treat precision as a contract, not only a performance knob.

## 25.3 Vector types

Odin supports SIMD-friendly vector types using fixed lane counts:

```odin
Vec4 :: #simd[4]f32

a := Vec4{1, 2, 3, 4}
b := Vec4{5, 6, 7, 8}
c := a + b
```

Operations apply lane-wise. The compiler maps suitable operations to target instructions when available.

## 25.4 Scalar reference first

Keep a clear scalar implementation:

```odin
dot_scalar :: proc(a, b: []f32) -> f32 {
    assert(len(a) == len(b))
    sum: f32
    for i in 0..<len(a) {
        sum += a[i] * b[i]
    }
    return sum
}
```

The scalar version defines semantics, supports unusual lengths, and provides a correctness oracle for vectorized implementations.

## 25.5 Chunking and tails

A vector loop handles full chunks, followed by a scalar tail:

```text
for each complete vector-width chunk:
    load
    compute
    accumulate
process remaining elements scalar
```

Never read beyond a valid slice merely because the hardware load is wide. Padding is acceptable only when ownership and allocation guarantee it.

## 25.6 Alignment

Modern CPUs often support unaligned loads, but alignment can still affect performance and is mandatory for some instructions or foreign APIs. Measure before adding complex alignment branches. If alignment is required, make it part of the allocator and API contract.

## 25.7 Array of structs versus struct of arrays

Suppose particles contain position, velocity, color, and lifetime. If one loop updates only positions and velocities, an array of large structs loads unrelated fields. A struct-of-arrays layout can provide contiguous numeric streams:

```odin
Particles :: struct {
    positions_x: []f32,
    positions_y: []f32,
    velocities_x: []f32,
    velocities_y: []f32,
}
```

Choose layout from access patterns, not ideology. Rendering or serialization may still benefit from interleaved structures.

## 25.8 Branches and masks

Divergent per-lane branches reduce SIMD efficiency. Sometimes a comparison mask and blend is clearer:

```text
mask = values < zero
result = select(mask, zero, values)
```

Do not replace simple predictable branches automatically. Profile real data distributions.

## 25.9 Reductions

Operations such as sum, minimum, or dot product collapse lanes into one value. Their order differs from a scalar left-to-right loop, especially for floating point. Parallel reduction can produce small numerical differences.

Specify whether the API promises exact reproducibility, tolerance-based equivalence, or best available precision.

## 25.10 Floating-point pitfalls

Floating-point addition is not associative:

```text
(a + b) + c may differ from a + (b + c)
```

Watch for:

- cancellation between similar large values;
- denormals and very small numbers;
- NaN propagation;
- infinities;
- signed zero;
- accumulated error in long sums.

Compensated summation or pairwise reduction may improve accuracy where needed.

## 25.11 Fast math

Aggressive fast-math options may reassociate expressions, ignore signed-zero distinctions, or assume NaNs and infinities do not occur. These changes can improve optimization but alter semantics.

Enable them only for a documented numerical domain with validation tests.

## 25.12 Auto-vectorization

Compilers can vectorize regular loops when aliasing and control flow are clear. Help them by:

- using contiguous slices;
- separating unrelated outputs;
- avoiding hidden calls inside hot loops;
- keeping loop bounds simple;
- removing unnecessary pointer aliasing;
- selecting release-like optimization.

Inspect generated code or profiler counters before assuming vectorization happened.

## 25.13 Cache and bandwidth

Many numeric kernels are limited by memory bandwidth rather than arithmetic throughput. If each element is read once for one addition, wider arithmetic may not help after bandwidth is saturated.

Measure bytes moved per useful operation. Fuse passes when it improves locality without destroying clarity or parallelism.

## 25.14 Benchmarking SIMD

Benchmark:

- several input sizes;
- aligned and representative unaligned data;
- warm and cold cache conditions when relevant;
- scalar and vector versions in the same build mode;
- realistic CPU targets;
- correctness against the reference implementation.

Report throughput and latency separately where meaningful.

## 25.15 Portability

A binary compiled for advanced instructions may fail on older CPUs. Choose a policy:

- conservative baseline target;
- separate builds by architecture level;
- runtime dispatch to specialized kernels;
- platform-specific implementation behind one API.

Keep feature detection and dispatch centralized.

## 25.16 Numerical API design

A strong numerical API states:

- accepted lengths and alignment;
- aliasing rules;
- precision and tolerance;
- NaN behavior;
- deterministic or architecture-dependent results;
- scratch memory requirements;
- supported target features.

Performance assumptions are part of the contract.

## 25.17 Common mistakes

### Vectorizing tiny workloads

Setup and horizontal reduction costs can dominate.

### Ignoring tails

Out-of-bounds vector loads are correctness bugs, not harmless optimization tricks.

### Comparing floats exactly

Vectorized evaluation order can change the least significant bits.

### Measuring only synthetic aligned arrays

Production data may have different sizes, alignment, and cache behavior.

## 25.18 Chapter checklist

You should now be able to:

- define SIMD vector types;
- preserve a scalar reference path;
- handle chunks and tails safely;
- choose layouts for numeric access patterns;
- reason about floating-point reductions;
- benchmark vector code and define portability policy.

## References

- [Odin SIMD overview](https://odin-lang.org/docs/overview/#simd)
- [IEEE 754 overview](https://standards.ieee.org/ieee/754/6210/)
- [Agner Fog optimization manuals](https://www.agner.org/optimize/)

---

[Exercises](../exercises/25-simd-numerical-code.md) · [Solutions](../solutions/25-simd-numerical-code.md)