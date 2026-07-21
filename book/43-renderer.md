# Chapter 43 — Renderer

[← Chapter 42: Platform Layer](42-platform-layer.md) · [Exercises](../exercises/43-renderer.md) · [Chapter 44: Asset Pipeline →](44-asset-pipeline.md)

The capstone renderer should be deliberately small. Its job is to transform immutable frame data into backend commands while keeping GPU resource lifetime, synchronization, and failure handling explicit.

## 43.1 Renderer boundary

The runtime world submits render-oriented data:

```odin
Render_Item :: struct {
    mesh: Mesh_Handle,
    material: Material_Handle,
    transform: Matrix4,
    bounds: Bounds,
}
```

The renderer must not walk gameplay components or query editor state. A render extraction phase converts world data into a frame packet.

## 43.2 Backend-independent handles

Expose engine handles for buffers, images, pipelines, and samplers. Store backend objects in internal pools. Generation checks reject stale handles and delay reuse until the GPU can no longer reference the old object.

## 43.3 Frame resources

Use multiple frames in flight. Each frame owns temporary command buffers, descriptor storage, upload memory, and deferred-destruction lists. Reuse them only after the corresponding fence or completion signal has fired.

## 43.4 Render graph thinking

Even a tiny renderer benefits from explicit passes:

1. upload pending resources;
2. shadow or depth prepass when needed;
3. main scene pass;
4. transparent pass;
5. editor overlays;
6. UI pass;
7. present.

Represent pass inputs, outputs, and ordering clearly. A full graph compiler is optional; hidden pass dependencies are not.

## 43.5 Pipeline state

Create pipelines from stable descriptions: shader set, vertex layout, blending, depth state, raster state, and render-target formats. Cache successful pipelines by description hash and retain diagnostics for failed compilation.

## 43.6 Resource uploads

CPU-visible staging memory feeds device-local resources. Batch uploads, track alignment, and associate completion with a frame or transfer fence. Never release source bytes before the backend has copied them.

## 43.7 Resize and swapchain recovery

Window resize, minimization, format changes, and device loss are normal states. Mark the presentation surface dirty and rebuild it at a safe point. Keep persistent renderer resources separate from swapchain-dependent resources.

## 43.8 Sorting and batching

Build sort keys from pass, pipeline, material, mesh, and depth policy. Opaque items usually prioritize state reduction; transparent items usually require back-to-front ordering. Measure before adding complex batching.

## 43.9 Culling

Start with frustum culling against bounds. Keep visibility output as compact indexes into render items. Later improvements can add spatial partitioning or GPU culling without changing world ownership.

## 43.10 Debug rendering

A line and primitive debug stream is invaluable. Give it explicit lifetime—one frame, timed, or persistent—and a bounded capacity. Debug drawing should not require creating gameplay entities.

## 43.11 Shader interface discipline

Treat shader inputs as an ABI. Define bindings, push constants, vertex attributes, coordinate conventions, and matrix layout in one place. Validate reflected shader metadata against the engine-side description where possible.

## 43.12 Diagnostics

Track:

- CPU render-build time;
- GPU pass times;
- visible and culled items;
- draw and dispatch counts;
- pipeline switches;
- uploaded bytes;
- transient-memory high-water marks;
- deferred-resource count;
- presentation failures.

## 43.13 Common mistakes

- letting gameplay issue backend calls;
- destroying GPU objects immediately after the CPU releases them;
- rebuilding all resources on resize;
- mixing persistent and frame-local descriptors;
- assuming successful shader compilation;
- sorting transparent and opaque objects identically;
- optimizing draw count while ignoring GPU bandwidth or synchronization.

## 43.14 Chapter checklist

You should have a render extraction boundary, stable handles, frames-in-flight ownership, explicit passes, upload and destruction policies, resize recovery, culling, shader-interface validation, and actionable metrics.

## References

- [Vulkan specification](https://registry.khronos.org/vulkan/)
- [Direct3D 12 documentation](https://learn.microsoft.com/windows/win32/direct3d12/direct3d-12-graphics)
- [WebGPU specification](https://www.w3.org/TR/webgpu/)