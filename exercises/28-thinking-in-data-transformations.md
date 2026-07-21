# Chapter 28 Exercises — Thinking in Data Transformations

[← Chapter](../book/28-thinking-in-data-transformations.md) · [Solutions →](../solutions/28-thinking-in-data-transformations.md)

1. Rewrite an object-centered particle update as explicit input/output transformations.
2. For a movement system, list all read sets, write sets, invariants, and possible aliasing hazards.
3. Design a batch API that updates 10,000 positions from velocities and acceleration.
4. Separate stable identity from dense storage for a collection whose elements are frequently removed.
5. Break an input-to-render frame into explicit phases and identify required barriers.
6. Find three duplicated-authority risks in a typical game engine and choose a canonical representation for each.
7. Design a deterministic command pipeline that normalizes, validates, and applies user commands.
8. Classify five subsystems as hot, warm, or cold and justify the representation used by each.

## Challenge

Implement a small simulation pipeline with three procedures: integrate motion, decrease lifetime, and compact expired items. Document every phase's read and write sets and verify that repeated runs produce identical output.
