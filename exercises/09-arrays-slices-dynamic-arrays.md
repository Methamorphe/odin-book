# Chapter 9 Exercises — Arrays, Slices and Dynamic Arrays

[← Chapter](../book/09-arrays-slices-dynamic-arrays.md) · [Solutions →](../solutions/09-arrays-slices-dynamic-arrays.md)

1. Declare a fixed array of eight `u8` values and compute its sum.
2. Demonstrate that assigning one array to another copies its elements.
3. Create a slice containing the middle three elements of a five-element array and mutate the backing array through it.
4. Write `average(values: []const f32) -> f32`.
5. Explain why returning a slice into a local array is invalid.
6. Create a dynamic array, reserve capacity, append 100 integers, and release its storage.
7. Show how appending can invalidate an earlier slice into a dynamic array.
8. Remove all odd values using write-cursor compaction.
9. Compare array-of-structs and struct-of-arrays layouts for a system that updates positions only.
10. Challenge: write `collect_positive(input: []const int, output: []int) -> int` without allocating.
