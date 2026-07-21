# Chapter 33 — Asset Registries and Resource Lifetime

[← Chapter 32: Job Systems and Frame Pipelines](32-job-systems-frame-pipelines.md) · [Exercises](../exercises/33-asset-registries-resource-lifetime.md) · [Chapter 34: Window Creation and Input →](34-window-creation-input.md)

Assets connect files, decoded CPU data, GPU resources, editor metadata, and runtime references. An asset registry centralizes identity and lifetime so the rest of the engine does not pass raw paths and pointers everywhere.

## 33.1 Asset identity

A path is a locator, not necessarily a stable identity. Paths can be renamed, normalized differently, or mapped to variants.

Useful asset identities include:

- generated UUIDs;
- stable content-pipeline IDs;
- normalized virtual paths;
- distinct typed handles.

Use typed handles to prevent mixing textures, meshes, sounds, and materials.

## 33.2 Registry records

A registry record may contain:

```text
identity
state
reference count or ownership policy
source path
content hash
version
CPU payload handle
GPU payload handle
last diagnostic
```

Keep hot runtime lookup data separate from large editor metadata when appropriate.

## 33.3 Explicit states

Asset loading is a state machine:

```text
Unloaded -> Queued -> Loading -> Ready
                         |          |
                         v          v
                       Failed <- Reloading
```

Callers should be able to distinguish loading, failed, and missing resources rather than receiving an ambiguous null pointer.

## 33.4 Two-stage loading

Many assets require at least two stages:

1. background I/O and decoding on worker threads;
2. final creation or upload on a thread with graphics or platform affinity.

The registry owns the transition and keeps intermediate data alive until the upload finishes.

## 33.5 Handles, not pointers

Registry storage may grow, compact, unload, or hot-reload. Public callers should keep handles and resolve them near use.

A stale handle must fail validation instead of silently resolving to a reused slot.

## 33.6 Ownership policies

Common policies include:

- strong reference counting;
- explicit acquire/release;
- owner-based lifetime by scene or world;
- cache retention with memory budget and LRU eviction;
- permanent engine assets;
- frame-local transient resources.

Choose one policy per resource category and document it. Mixing implicit ownership models creates leaks and premature destruction.

## 33.7 Reference counts are not enough

Reference counting does not solve:

- cycles;
- GPU synchronization;
- pending jobs;
- in-flight render commands;
- external API ownership;
- memory-budget eviction.

A resource can have zero logical users while still being referenced by an upload job or current command buffer.

## 33.8 Deferred destruction

GPU resources often cannot be destroyed immediately after the last gameplay reference disappears. Queue destruction until the GPU has completed all work that references the resource.

This can be represented by:

- frame-delayed destruction queues;
- fences or timeline values;
- per-frame resource retirement lists.

## 33.9 Hot reload

Hot reload should preserve public identity while replacing internal payloads.

A safe sequence is:

1. detect source change;
2. build a new payload independently;
3. validate it;
4. atomically publish the replacement at a synchronization point;
5. retire the old payload when no in-flight work uses it.

Do not destroy the working asset before the replacement succeeds.

## 33.10 Dependency graphs

Assets depend on other assets:

- materials depend on textures and shaders;
- scenes depend on meshes and materials;
- animations depend on skeletons;
- prefabs depend on nested prefabs.

Track dependencies to support reload propagation, packaging, diagnostics, and cycle detection.

## 33.11 Content hashes and versions

A content hash can detect identical payloads and support build caches. A registry version can tell consumers whether a resolved payload changed.

Do not confuse source timestamps with content identity. Timestamps are useful hints but can be coarse or unreliable.

## 33.12 Fallback resources

Rendering and audio systems often need safe fallbacks:

- checkerboard texture;
- error shader;
- silent audio clip;
- placeholder mesh.

Fallbacks keep the application operational while diagnostics remain visible. They should not hide failures from tooling or logs.

## 33.13 Memory budgets

Track memory by category:

- source bytes;
- decoded CPU data;
- GPU allocations;
- streaming buffers;
- temporary import memory.

Eviction should consider cost, recency, dependencies, and whether a resource is currently pinned.

## 33.14 Packaging and virtual paths

Runtime code should use a virtual asset namespace rather than assuming loose files. The same handle may resolve from:

- development source trees;
- packed archives;
- downloaded content;
- platform-specific bundles.

Keep locator policy behind the registry or virtual file system.

## 33.15 Diagnostics

A useful asset inspector shows:

- state and generation;
- source and resolved locator;
- dependency chain;
- reference owners;
- CPU and GPU memory;
- load duration;
- last reload time;
- current error.

## 33.16 Common mistakes

### Using paths as references everywhere

Renames and packaging become painful, and type safety is lost.

### Publishing partially initialized assets

Build the replacement completely before making it visible.

### Destroying GPU data immediately

Logical lifetime and device lifetime are not identical.

### Silent fallback

Fallback resources should preserve diagnostics.

### Registry as a global dumping ground

Keep clear APIs and typed categories instead of exposing arbitrary mutable maps.

## References

- [Odin Overview](https://odin-lang.org/docs/overview/)
- [Vulkan Guide — Resource Management](https://vkguide.dev/docs/chapter-4/storage_buffers/)
- [Bitsquid Foundation — Resource Management](https://bitsquid.blogspot.com/2011/09/managing-decoupling-part-5-resource.html)
