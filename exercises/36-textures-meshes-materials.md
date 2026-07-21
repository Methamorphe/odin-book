# Chapter 36 Exercises — Textures, Meshes, and Materials

[← Chapter](../book/36-textures-meshes-materials.md) · [Solutions](../solutions/36-textures-meshes-materials.md)

1. Define runtime metadata for a mesh with indexed geometry.
2. Compare interleaved and separate vertex streams for three concrete passes.
3. Choose between `u16` and `u32` index buffers for several vertex counts.
4. Classify base-color, normal, roughness, and emissive textures as linear or sRGB.
5. Design a material template and a lightweight material instance.
6. Specify the states of an asynchronous texture upload pipeline.
7. Define mesh bounds and a conservative world-space update rule.
8. Propose an opaque draw sorting key.

## Challenge

Design an asset-to-GPU pipeline that imports a mesh and its textures, validates every artifact, uploads asynchronously, exposes fallback resources during loading, and supports hot reload without invalidating durable asset handles.