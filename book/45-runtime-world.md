# Chapter 45 — Runtime World

[← Chapter 44: Asset Pipeline](44-asset-pipeline.md) · [Exercises](../exercises/45-runtime-world.md) · [Chapter 46: Editor →](46-editor.md)

The runtime world owns simulation state. It should be compact, explicit, serializable where required, and independent from editor widgets or rendering backends.

## 45.1 World responsibilities

The world manages:

- stable entity identity;
- component storage;
- system scheduling;
- scene instantiation;
- spatial queries;
- gameplay events;
- saveable state;
- deterministic fixed-step updates where required.

Rendering, audio, and editor packages consume extracted data or commands rather than owning simulation objects.

## 45.2 Entity identity

Use an index plus generation. Destruction increments the generation and returns the slot to a free list. Every external reference validates both fields before access.

Do not serialize transient slot indexes as durable identity. Saved data should use stable scene or object IDs that can be remapped during load.

## 45.3 Component storage

Choose storage per access pattern:

- dense arrays for components iterated every frame;
- sparse sets for optional components;
- maps for rare editor-oriented lookup;
- fixed pools for bounded high-frequency objects;
- blobs for immutable authored data.

One universal container is rarely optimal.

## 45.4 Structural changes

Adding or removing components can invalidate iteration. Queue structural commands during system execution and apply them at a synchronization point. The command buffer also creates a clear record for debugging and replay.

## 45.5 Systems

A system declares the data it reads and writes. Keep its input as slices or narrow world views. This enables dependency analysis and later parallel scheduling.

```text
Input → Character Intent → Physics → Gameplay → Animation → Extraction
```

Avoid hidden procedure calls that mutate unrelated subsystems during iteration.

## 45.6 Fixed-step simulation

Accumulate frame time and execute zero or more fixed updates. Clamp the accumulator after stalls. Keep random seeds, input commands, and external events explicit if replay or deterministic debugging matters.

## 45.7 Events

Use events for facts that occurred, not as a substitute for direct data flow. Distinguish immediate local events from queued cross-system events. Bound queues and define overflow policy.

Events should carry stable values or handles, not pointers into component arrays that may move.

## 45.8 Scene instantiation

A scene artifact describes templates and references. Loading creates runtime entities, resolves local references through a remap table, and records ownership by scene instance. Unloading destroys the owned entities through the same structural command path.

## 45.9 Save data

Save only durable gameplay state. Do not dump raw component memory. Use versioned records, stable IDs, explicit optional fields, and migration procedures. Asset handles should serialize as stable asset IDs.

## 45.10 Render extraction

After simulation, iterate renderable components and produce a frame-local array of render items. Copy only data required by the renderer. This snapshot prevents the renderer from racing with simulation or depending on ECS internals.

## 45.11 Spatial queries

Start with a simple broad phase appropriate to the game: uniform grid, sweep-and-prune, or bounded linear scans. Define query results as handles and validate them when consumed.

## 45.12 Debugging

Useful world diagnostics include:

- entity and component counts;
- free-list size;
- structural-command count;
- per-system duration;
- event queue occupancy;
- scene ownership;
- invalid-handle attempts;
- fixed-step count and accumulated lag.

## 45.13 Common mistakes

- exposing component pointers as long-lived references;
- changing storage while iterating it;
- letting rendering own transforms;
- serializing raw memory layouts;
- using events for ordinary procedure calls;
- making every system depend on the full world;
- confusing authored scene identity with runtime entity identity.

## 45.14 Chapter checklist

You should have generational entities, appropriate component storage, queued structural changes, explicit system access, fixed-step simulation, stable scene loading, versioned saves, render extraction, and world diagnostics.

## References

- [Entity Component System FAQ](https://github.com/SanderMertens/ecs-faq)
- [Game Programming Patterns](https://gameprogrammingpatterns.com/)
- [Data-Oriented Design](https://www.dataorienteddesign.com/dodbook/)