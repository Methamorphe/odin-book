# Chapter 35 — Rendering Fundamentals

[← Chapter 34: Window Creation and Input](34-window-creation-input.md) · [Exercises](../exercises/35-rendering-fundamentals.md) · [Chapter 36: Textures, Meshes, and Materials →](36-textures-meshes-materials.md)

Rendering converts a scene description into pixels. The important skill is not memorizing one graphics API. It is understanding the pipeline, the ownership model, and the synchronization rules well enough to build a renderer that remains inspectable.

## 35.1 Renderer architecture

Separate three concerns:

- the application describes what should be drawn;
- the renderer builds commands and manages GPU resources;
- the backend translates commands to OpenGL, Vulkan, Direct3D, Metal, WebGPU, or another API.

A render API should expose engine concepts rather than every backend detail.

## 35.2 The graphics pipeline

A simplified raster pipeline performs:

1. vertex fetch;
2. vertex transformation;
3. primitive assembly;
4. clipping and rasterization;
5. fragment shading;
6. depth and stencil tests;
7. blending;
8. attachment writes.

Each stage consumes a specific data representation. Most rendering bugs are mismatches between those representations.

## 35.3 Coordinate spaces

A vertex commonly travels through:

```text
model space → world space → view space → clip space → NDC → viewport
```

Keep matrix conventions explicit: handedness, row versus column vectors, multiplication order, depth range, and clip-space orientation must agree across math code and shaders.

## 35.4 GPU resources

Buffers, textures, samplers, pipelines, descriptor sets, and render targets have explicit lifetimes. Represent them with typed handles rather than raw backend pointers:

```odin
Buffer_Handle   :: distinct u32
Texture_Handle  :: distinct u32
Pipeline_Handle :: distinct u32
```

Use generations or validation in debug builds to detect stale resources.

## 35.5 Command submission

Avoid issuing backend calls from arbitrary gameplay code. Build a compact command stream or render packet:

```odin
Draw_Command :: struct {
    pipeline: Pipeline_Handle,
    vertex_buffer: Buffer_Handle,
    index_count: u32,
    first_index: u32,
}
```

The renderer can sort, validate, batch, and submit these commands centrally.

## 35.6 Render passes

A render pass declares which attachments are read or written and how they begin and end. Even when using an immediate API, thinking in passes clarifies dependencies:

- shadow pass;
- geometry or forward pass;
- transparent pass;
- post-processing;
- user interface.

Explicit pass boundaries make future render-graph work easier.

## 35.7 Depth, culling, and blending

Depth testing resolves visibility for opaque geometry. Face culling removes triangles facing away from the camera. Blending combines source and destination colors, usually requiring back-to-front ordering for transparent surfaces.

Treat pipeline state as immutable or cacheable configuration. Hidden global state makes rendering difficult to reason about.

## 35.8 Frames in flight

The CPU and GPU execute asynchronously. A resource submitted this frame may still be in use later. Use fences, frame indices, and deferred destruction queues. Never immediately reuse or destroy memory merely because submission returned.

## 35.9 Upload strategy

Static assets can use staging buffers and device-local memory. Frequently updated values belong in ring buffers, mapped upload memory, or per-frame allocations. Measure before introducing complex streaming systems.

## 35.10 Debugging rendering

Build observability into the renderer:

- debug labels and markers;
- validation layers;
- command counters;
- pipeline and resource names;
- wireframe and overdraw modes;
- capture support for RenderDoc or vendor tools.

A black screen is not a useful diagnostic category. Validate each pipeline boundary.

## 35.11 Choosing a first backend

For learning, a simple vendor binding such as raylib or OpenGL can reduce setup cost. For a production-oriented abstraction, Vulkan, Direct3D 12, Metal, or WebGPU expose explicit resource and synchronization models. Choose according to the project's goals, not prestige.

## 35.12 Common mistakes

- mixing coordinate conventions;
- scattering draw calls throughout gameplay code;
- destroying in-flight resources;
- relying on undocumented global state;
- rebuilding pipelines every frame;
- allocating per draw command without a frame allocator;
- optimizing batching before measuring submission cost.

## 35.13 Chapter checklist

You should understand the raster pipeline, coordinate transformations, GPU resource lifetime, command submission, render passes, synchronization, and the role of validation tools.

## References

- [Vulkan Guide](https://vkguide.dev/)
- [WebGPU specification](https://www.w3.org/TR/webgpu/)
- [RenderDoc](https://renderdoc.org/)
- [Odin vendor packages](https://pkg.odin-lang.org/vendor/)
