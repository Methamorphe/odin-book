# Chapter 35 Solutions — Rendering Fundamentals

[← Exercises](../exercises/35-rendering-fundamentals.md) · [Chapter](../book/35-rendering-fundamentals.md)

1. Vertex fetch → vertex shading → primitive assembly → rasterization → fragment shading → tests/blending → attachment writes.
2. `model → world → view → clip → NDC → viewport`; conventions must be centralized.
3. Use distinct integer-backed handle types and validate generations in debug builds.
4. Include pipeline, vertex/index buffers, material or descriptor handle, index count, first index, vertex offset, and sort key.
5. Each pass declares attachments, load/store behavior, viewport, and its command range.
6. Submission is asynchronous; the GPU may still read the resource after the CPU has moved on. Retire resources only after the relevant fence completes.
7. Divide upload memory by frame-in-flight index, align allocations, wrap only after the owning fence completes, and fail visibly on overflow.
8. Validate swapchain extent, pass begin/end, pipeline creation, shader compilation, vertex layout, resource bindings, viewport/scissor, depth state, and captures.

## Challenge outline

The public API should consume descriptions and typed handles. A backend-owned table stores native objects. `destroy_*` enqueues retirement tagged with the current frame/fence rather than freeing immediately.