# Chapter 37 — Cameras, Transforms, and Scenes

[← Chapter 36: Textures, Meshes, and Materials](36-textures-meshes-materials.md) · [Exercises](../exercises/37-cameras-transforms-scenes.md) · [Chapter 38: Audio and Event Systems →](38-audio-event-systems.md)

Scenes connect spatial data to rendering. The central challenge is not storing objects in a tree; it is maintaining transforms, visibility, identity, and update order without turning every object into a tightly coupled class.

## 37.1 Transform data

A local transform typically contains translation, rotation, and scale:

```odin
Transform :: struct {
    position: [3]f32,
    rotation: [4]f32,
    scale: [3]f32,
}
```

Store the authoring representation separately from the cached world matrix when appropriate. Quaternions should be normalized, and non-uniform scale requires care when transforming normals.

## 37.2 Hierarchies

A parent-child hierarchy composes local transforms into world transforms. Use stable entity or node handles, not pointers into growable arrays. A flat node array with parent indices is often simpler and more cache-friendly than heap-allocated tree nodes.

## 37.3 Dirty propagation

Recomputing every world transform can be acceptable for small scenes. Larger scenes benefit from dirty flags or version counters. When a parent changes, descendants must observe that change. Version-based propagation can avoid recursively marking entire subtrees.

## 37.4 Update order

Parents must be updated before children. Maintain a topological order or traverse roots deterministically. Reject cycles when editing hierarchy relationships.

## 37.5 Cameras

A camera defines view and projection transforms plus rendering metadata:

```odin
Camera :: struct {
    near_plane: f32,
    far_plane: f32,
    vertical_fov_radians: f32,
    aspect_ratio: f32,
}
```

The view matrix is the inverse of the camera's world transform. Projection conventions must match the rendering backend.

## 37.6 Perspective and orthographic projection

Perspective projection models depth-dependent size and is common for 3D views. Orthographic projection preserves scale and is useful for UI, editors, strategy views, and shadow maps. Keep projection construction centralized so clip-space differences remain isolated.

## 37.7 Frustum culling

Extract frustum planes from the combined view-projection transform or construct them geometrically. Test world-space bounds before creating draw commands. Culling should be conservative: false positives cost performance, false negatives create missing objects.

## 37.8 Scene versus world

A scene graph is not necessarily the entire game world. Simulation data may live in ECS tables, while a render scene contains only spatial and visual snapshots. Avoid forcing audio, gameplay, physics, and rendering to share one universal object hierarchy.

## 37.9 Render extraction

At a defined frame phase, extract visible render data from the simulation world into a renderer-owned snapshot. This creates a clean synchronization boundary and allows the renderer to sort or process data independently.

## 37.10 Large worlds

Large coordinate magnitudes reduce floating-point precision. Techniques include origin rebasing, camera-relative rendering, chunk-local coordinates, and double precision for high-level positions with `f32` render-relative data.

## 37.11 Editor concerns

Editors need selection IDs, gizmo spaces, parent changes that preserve world transforms, undoable operations, and hierarchy validation. Keep authoring metadata out of performance-critical runtime arrays when it is not needed in shipping builds.

## 37.12 Common mistakes

- storing pointers to nodes in movable arrays;
- allowing hierarchy cycles;
- mixing projection conventions;
- treating the scene graph as every subsystem's data model;
- updating child transforms before parents;
- performing culling after expensive draw preparation;
- using large absolute `f32` coordinates without a precision plan.

## 37.13 Chapter checklist

You should be able to represent local and world transforms, update hierarchies deterministically, configure cameras, perform conservative culling, and separate simulation state from render-scene extraction.

## References

- [Real-Time Rendering resources](https://www.realtimerendering.com/)
- [Graphics Gems](https://www.realtimerendering.com/resources/GraphicsGems/)
- [glTF node transforms](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#nodes-and-hierarchy)
