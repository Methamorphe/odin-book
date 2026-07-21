# Chapter 37 Exercises — Cameras, Transforms, and Scenes

[← Chapter](../book/37-cameras-transforms-scenes.md) · [Solutions](../solutions/37-cameras-transforms-scenes.md)

1. Define local transform data and a cached world transform.
2. Implement parent-before-child ordering for a flat hierarchy.
3. Design cycle detection when reparenting a node.
4. Compare dirty flags with version counters.
5. Explain how to construct a camera view matrix.
6. Choose perspective or orthographic projection for four scenarios.
7. Design conservative frustum culling for world-space bounds.
8. Explain render extraction from simulation state.

## Challenge

Design a scene subsystem supporting stable node handles, reparenting while preserving world transforms, dirty propagation, camera-relative rendering, visibility extraction, and editor selection.