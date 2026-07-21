# Chapter 28 Solutions — Thinking in Data Transformations

[← Exercises](../exercises/28-thinking-in-data-transformations.md) · [Chapter →](../book/28-thinking-in-data-transformations.md)

1. Represent particle state as dense slices and express updates as procedures over those slices rather than per-particle methods.
2. Movement reads velocity and delta time, writes position, requires equal slice lengths, and must reject unsupported overlapping outputs.
3. A suitable API accepts `positions`, `velocities`, `accelerations`, and `dt`, validates lengths once, then processes a dense range.
4. Expose a generational handle while keeping a separate dense index mapping internally.
5. A typical sequence is input, normalized commands, simulation, collision, event resolution, extraction, rendering. Barriers are required before a phase consumes writes from parallel jobs.
6. Common duplicated truths include local/world transforms, source/compiled assets, and simulation/render state. Choose one authority and derive or explicitly synchronize the others.
7. Preserve command order with a stable sequence number, validate without mutation, then apply accepted commands in sorted order.
8. Simulation, rendering extraction, and audio mixing are often hot; asset loading is warm; menus and diagnostics are usually cold. Actual profiling remains authoritative.

## Challenge outline

Use parallel slices for position, velocity, and lifetime. Run the three phases in a fixed order. Compact with swap-delete or a write cursor, and compare final arrays across repeated runs with identical input.
