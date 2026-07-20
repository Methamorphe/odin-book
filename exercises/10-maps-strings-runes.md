# Chapter 10 Exercises — Maps, Strings and Runes

[← Chapter](../book/10-maps-strings-runes.md) · [Solutions →](../solutions/10-maps-strings-runes.md)

1. Build a `map[string]int` that counts repeated words.
2. Demonstrate why lookup must return both a value and a presence flag.
3. Produce deterministic map output by collecting and sorting keys.
4. Compare a map with a sorted array for a read-only collection of 12 entries.
5. Show that `len(string)` counts bytes, not user-perceived characters.
6. Slice an ASCII prefix safely, then explain why the same byte offsets may split UTF-8 text.
7. Explain the difference between bytes, runes, and grapheme clusters.
8. Design an API that clearly distinguishes a borrowed string view from an allocated string.
9. Parse tokens as borrowed slices of an input buffer and state the lifetime requirement.
10. Challenge: design a string-interning table that returns distinct integer IDs and documents its lifetime.
