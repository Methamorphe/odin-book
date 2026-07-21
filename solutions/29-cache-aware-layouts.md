# Chapter 29 Solutions — Cache-Aware Layouts

[← Exercises](../exercises/29-cache-aware-layouts.md) · [Chapter →](../book/29-cache-aware-layouts.md)

1. AoS favors systems consuming complete records; SoA favors loops touching only selected fields.
2. Keep frequently updated transforms and flags together; move names, annotations, paths, and editor state to cold storage.
3. Padding depends on alignment and field order. Measure instead of assuming the visually smallest declaration is best.
4. Column-first traversal jumps by row stride, wasting cache lines and defeating regular prefetching.
5. Move the last dense item into the removed slot, shorten storage, then update the moved item's reverse mapping.
6. Separate frequently written worker counters onto distinct cache lines or aggregate per-worker values after the phase.
7. Use realistic counts, optimized builds, repeated runs, consumed outputs, and correctness checks before timing.
8. Store transform columns in chunks, keep health in a separate optional column or sparse set, and place editor metadata behind handles.

## Challenge outline

Initialize both layouts from identical generated data. Run the same number of iterations, checksum outputs, and compare median timings rather than a single run.
