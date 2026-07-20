# Chapter 14 Exercises — The Odin Memory Model

[← Chapter](../book/14-memory-model.md) · [Solutions](../solutions/14-memory-model.md)

1. Classify ten sample values by stack, static, allocator-managed, or foreign storage.
2. Draw the ownership graph for a `World` containing dynamic entity arrays and borrowed system views.
3. Explain why copying a slice does not duplicate its elements.
4. Find all dangling-view risks in a parser that returns slices into a temporary input buffer.
5. Compare two struct field orders with `size_of`, `align_of`, and `offset_of`.
6. Design lifetimes for persistent world data, per-frame scratch data, and GPU submission buffers.
