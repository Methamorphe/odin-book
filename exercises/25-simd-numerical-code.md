# Chapter 25 Exercises — SIMD and Numerical Code

[← Chapter](../book/25-simd-numerical-code.md) · [Solutions](../solutions/25-simd-numerical-code.md)

1. Implement a scalar dot product and define its behavior for unequal lengths.
2. Rewrite the loop conceptually in four-lane chunks and handle the tail without reading out of bounds.
3. Compare AoS and SoA layouts for updating particle positions while rendering interleaved vertices.
4. Explain why a SIMD sum may differ from a scalar left-to-right sum.
5. Design tests covering NaN, infinity, signed zero, cancellation, and very small values.
6. Determine whether a one-operation-per-element kernel is compute-bound or bandwidth-bound and state what to measure.
7. Create a benchmark matrix across input sizes, alignment, scalar/SIMD versions, and warm/cold cache conditions.
8. Propose a portability strategy for baseline CPUs and an AVX-capable optimized kernel.

## Challenge

Implement a normalized-vector batch operation with a scalar reference, SIMD chunk path, zero-length-vector policy, tolerance tests, and benchmark report.