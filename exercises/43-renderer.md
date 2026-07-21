# Chapter 43 — Exercises

[← Chapter](../book/43-renderer.md) · [Solutions](../solutions/43-renderer.md)

1. Define a render extraction packet independent from ECS storage.
2. Model generational handles for GPU resources.
3. Design resources for three frames in flight.
4. Specify a minimal render-pass dependency graph.
5. Build a pipeline description and cache key.
6. Design deferred destruction after GPU completion.
7. Define opaque and transparent sort keys.
8. List renderer metrics required for diagnosis.

## Challenge

Design the complete lifetime of a texture from asset load through upload, use across several frames, hot replacement, and safe GPU destruction.