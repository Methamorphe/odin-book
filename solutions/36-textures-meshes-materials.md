# Chapter 36 Solutions — Textures, Meshes, and Materials

[← Exercises](../exercises/36-textures-meshes-materials.md) · [Chapter](../book/36-textures-meshes-materials.md)

1. Store vertex/index buffer handles, index count/type, vertex layout, topology, and local bounds. Source names and decoder objects stay outside runtime data.
2. Interleaving suits a forward pass consuming all attributes. Separate position streams benefit shadow/depth passes. Dynamic skinning data may update separately from static UVs.
3. Use `u16` up to 65,535 addressable vertices; otherwise use `u32`. Split meshes only when the asset pipeline and batching policy justify it.
4. Base color and emissive color are usually sRGB. Normal, roughness, metallic, masks, and data textures are linear.
5. The template identifies shader family and fixed layout. The instance stores compact parameter values and texture handles.
6. `Unloaded → Importing → Validated → Upload_Queued → Uploading → Ready`, with `Failed` and optional `Evicted` states.
7. Store an AABB or sphere in local space. Transform all AABB corners or use a conservative center/extents method; non-uniform scale must be handled.
8. Pack pass, pipeline, material, and depth bucket according to desired priority. Preserve a stable tie-breaker for debugging.

## Challenge outline

Durable asset handles resolve through the registry to a current GPU-resource generation. Reload creates new GPU resources, atomically swaps the resolved version at a frame boundary, and retires old resources after fences complete.