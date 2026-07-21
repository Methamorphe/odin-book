# Chapter 36 — Textures, Meshes, and Materials

[← Chapter 35: Rendering Fundamentals](35-rendering-fundamentals.md) · [Exercises](../exercises/36-textures-meshes-materials.md) · [Chapter 37: Cameras, Transforms, and Scenes →](37-cameras-transforms-scenes.md)

Renderers become useful when they can represent reusable assets. Meshes describe geometry, textures describe sampled data, and materials bind data to shader behavior.

## 36.1 Mesh representation

A mesh commonly owns or references:

- vertex buffers;
- an optional index buffer;
- vertex layout metadata;
- primitive topology;
- local-space bounds.

Keep CPU import data separate from the compact runtime representation. Runtime meshes should contain only what submission needs.

## 36.2 Vertex layouts

A vertex layout defines attribute semantics, formats, offsets, and stride. Avoid assuming every mesh uses one giant vertex structure. Position-only shadow geometry and skinned geometry have different requirements.

Interleaved attributes improve locality when all attributes are consumed together. Separate streams are useful when passes consume subsets or data updates at different frequencies.

## 36.3 Index buffers

Index buffers reuse vertices and reduce duplicate transform work. Choose `u16` when the vertex count permits and `u32` otherwise. The index type is part of the draw contract.

## 36.4 Texture concepts

A texture has dimensions, format, mip levels, layers, usage flags, and color-space interpretation. Distinguish linear data from sRGB color data. Normal maps, roughness, and masks must not be sampled as display color.

## 36.5 Mipmaps and filtering

Mipmaps reduce aliasing and bandwidth at distance. Samplers define minification, magnification, mip filtering, wrapping, comparison, and anisotropy. Keep sampler state separate from image storage when the backend allows it.

## 36.6 Materials

A material is a parameter set for a shader family, not a bag of arbitrary renderer state:

```odin
Material_Data :: struct {
    base_color: [4]f32,
    roughness: f32,
    metallic: f32,
    base_color_texture: Texture_Handle,
}
```

Separate immutable template data from per-instance overrides. This enables batching and predictable layouts.

## 36.7 Resource handles

Meshes, textures, and materials should be referenced through validated handles. Asset identity and GPU residency are different concerns: an asset can remain known while its current GPU resource is reloaded or evicted.

## 36.8 Upload pipeline

Import and GPU upload are separate stages:

```text
source file → decoded/imported data → validated artifact → runtime upload → ready handle
```

Do not decode image formats or parse meshes in the render thread. Upload commands should consume prepared data.

## 36.9 Bounds and culling

Store local-space bounding boxes or spheres with meshes. Transform bounds conservatively into world space and cull before generating draw commands.

## 36.10 Material sorting

Sort opaque draws to reduce pipeline and material changes. Transparent draws usually require depth ordering. Sorting keys should be explicit and stable enough for debugging.

## 36.11 Streaming and fallback resources

A resource may be loading, resident, failed, or evicted. Render with fallback textures and meshes instead of blocking the frame. Resource state belongs in the asset registry, while submission uses resolved runtime handles.

## 36.12 Common mistakes

- treating all texture data as sRGB;
- coupling source-file objects directly to GPU resources;
- hiding vertex layout assumptions;
- rebuilding materials every frame;
- blocking rendering on asset decoding;
- using raw pointers as durable resource references;
- omitting bounds from runtime mesh data.

## 36.13 Chapter checklist

You should be able to define mesh and texture metadata, choose vertex layouts, model materials, separate import from upload, and integrate resources with stable asset handles.

## References

- [glTF 2.0 specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html)
- [Khronos texture formats](https://www.khronos.org/opengl/wiki/Image_Format)
- [Odin vendor packages](https://pkg.odin-lang.org/vendor/)
