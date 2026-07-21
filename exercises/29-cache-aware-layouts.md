# Chapter 29 Exercises — Cache-Aware Layouts

[← Chapter](../book/29-cache-aware-layouts.md) · [Solutions →](../solutions/29-cache-aware-layouts.md)

1. Model particles as AoS and SoA and list which systems favor each layout.
2. Split a large entity record into hot and cold data.
3. Use `size_of` and `align_of` to inspect three field orderings of the same struct.
4. Explain why column-first traversal is inefficient for a row-major image.
5. Design swap-delete removal while preserving an external index mapping.
6. Identify a false-sharing risk in per-worker statistics and propose a fix.
7. Write a benchmark plan comparing AoS and SoA without allowing dead-code elimination.
8. Design a hybrid chunk layout for transforms, health, and editor metadata.

## Challenge

Implement AoS and SoA versions of a motion update over at least 100,000 elements. Validate identical results and benchmark optimized builds.
