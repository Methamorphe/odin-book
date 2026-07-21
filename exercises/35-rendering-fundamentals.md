# Chapter 35 Exercises — Rendering Fundamentals

[← Chapter](../book/35-rendering-fundamentals.md) · [Solutions](../solutions/35-rendering-fundamentals.md)

1. List the major raster pipeline stages and the representation exchanged between each.
2. Draw the complete model-to-viewport coordinate path.
3. Define typed handles for buffers, textures, and pipelines.
4. Design a compact indexed `Draw_Command`.
5. Split a frame into shadow, opaque, transparent, post-process, and UI passes.
6. Explain why GPU resource destruction must often be deferred.
7. Design a per-frame upload ring buffer policy.
8. Create a black-screen diagnostic checklist.

## Challenge

Specify a minimal renderer API that can create buffers and pipelines, begin passes, submit indexed draws, present, and defer resource destruction without exposing backend objects.