# Chapter 31 — Entity-Component Systems

[← Chapter 30: Handles, Generations, and Object Pools](30-handles-generations-object-pools.md) · [Exercises](../exercises/31-entity-component-systems.md) · [Chapter 32: Job Systems and Frame Pipelines →](32-job-systems-frame-pipelines.md)

An entity-component system organizes simulation state around composition and bulk processing. Entities provide identity, components provide data, and systems transform matching component sets.

ECS is not one rigid architecture. Sparse sets, archetypes, tables, and simple parallel arrays all fit the same broad model while making different trade-offs.

## 31.1 Entities are identifiers

An entity should contain little or no behavior. It is usually a generational handle:

```odin
Entity :: struct {
    index: u32,
    generation: u32,
}
```

The handle answers “which logical lifetime?” Components answer “what data exists for it?”

## 31.2 Components are data

Good components are focused data records:

```odin
Position :: struct { x, y: f32 }
Velocity :: struct { x, y: f32 }
Health   :: struct { current, maximum: i32 }
```

Avoid placing broad subsystem ownership, hidden allocation, or unrelated behavior inside every component.

## 31.3 Systems are transformations

A movement system reads velocity and writes position:

```text
(Position, Velocity, dt) -> Position
```

A damage system may consume queued damage events and write health. A rendering extraction system reads transforms and visual components and writes a transient render list.

Explicit read/write sets become the basis for scheduling and parallelism.

## 31.4 The simplest ECS

A small project can begin with:

- a fixed or dynamic entity pool;
- one array per component type;
- a presence flag per entity index;
- systems iterating valid combinations.

This is often enough for prototypes and educational engines. Do not jump to archetype migration machinery before requirements justify it.

## 31.5 Sparse sets

A sparse set maintains:

- a dense array of component values;
- a dense array of entity IDs;
- a sparse array mapping entity index to dense position.

Membership tests are fast, iteration is dense, and swap-delete removal is efficient. The moved entity's sparse mapping must be updated.

Sparse sets work well when components are added and removed independently.

## 31.6 Archetype storage

An archetype groups entities that share the same component signature. Each archetype stores columns for those components.

Advantages:

- extremely dense iteration for matching queries;
- strong cache locality;
- natural chunk-level scheduling.

Costs:

- adding or removing a component moves an entity between archetypes;
- implementation complexity;
- more elaborate query caching and structural command handling.

## 31.7 Structural changes

Creating entities, destroying entities, or changing component composition can invalidate iteration. Common solutions include:

- defer structural changes until the end of a phase;
- record commands in a command buffer;
- apply changes at synchronization points;
- prohibit structural mutation inside selected systems.

This also makes parallel execution easier.

## 31.8 Query design

A query describes required, optional, and excluded components:

```text
required: Position, Velocity
excluded: Sleeping
optional: Acceleration
```

The implementation should avoid repeated expensive discovery. Cache matching archetypes or choose a smallest dense component set for sparse-set iteration.

## 31.9 Component ownership

Not all data belongs in ECS storage. Assets, global services, platform handles, and large immutable resources may be referenced by handles instead.

Use ECS for state that benefits from entity composition and bulk system processing—not as a universal container for the whole application.

## 31.10 Events and commands

Events represent facts that happened. Commands represent requested future mutations.

Examples:

- event: `Entity_Died`;
- command: `Spawn_Explosion`;
- event: `Animation_Finished`;
- command: `Remove_Component`.

Buffers should have explicit lifetime and ordering. Avoid an uncontrolled global event bus that permits any subsystem to mutate anything immediately.

## 31.11 Determinism and ordering

System order matters when systems write data consumed later in the same frame. Define the pipeline explicitly:

```text
input -> intent -> movement -> collision -> damage -> cleanup
```

When deterministic simulation matters, also control:

- entity iteration order;
- command application order;
- floating-point behavior;
- parallel reduction order;
- random-number streams.

## 31.12 ECS and multithreading

Systems can run concurrently when their read/write sets do not conflict. For example:

- two readers can overlap;
- a reader and writer of the same component conflict;
- two writers conflict unless ranges are partitioned safely.

A scheduler can derive dependencies from these access declarations, but explicit hand-authored phases are a good starting point.

## 31.13 Debugging and tooling

Useful ECS diagnostics include:

- entity inspector by handle;
- component list;
- archetype or sparse-set membership;
- system timing;
- entity and component counts;
- structural command queue size;
- stale handle reports.

Tooling needs should influence APIs early, but editor-only metadata can remain outside hot component arrays.

## 31.14 Common mistakes

### Building a framework before a game

Implement only the features demanded by actual systems and workloads.

### Components with hidden cross-system side effects

Components should remain understandable data contracts.

### Immediate structural mutation during iteration

This creates invalidation bugs and blocks parallelization.

### Treating entities as objects with methods

That reintroduces scattered per-object behavior and weakens batch processing.

## References

- [Odin Overview](https://odin-lang.org/docs/overview/)
- [EnTT: Crash Course — Entity Component System](https://github.com/skypjack/entt/wiki/Crash-Course:-entity-component-system)
- [Overwatch Gameplay Architecture and Netcode](https://www.gdcvault.com/play/1024001/Overwatch-Gameplay-Architecture-and-Netcode)
