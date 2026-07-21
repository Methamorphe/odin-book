# Chapter 31 Exercises — Entity-Component Systems

[← Chapter](../book/31-entity-component-systems.md) · [Solutions →](../solutions/31-entity-component-systems.md)

1. Define entity identity separately from component data.
2. Build a minimal position/velocity store using presence flags.
3. Describe sparse-set insertion, membership, and swap-delete removal.
4. Compare sparse-set and archetype storage for a game with frequent composition changes.
5. Design a command buffer for deferred entity destruction.
6. Declare read/write sets for movement, collision, damage, and rendering extraction.
7. Define a deterministic system order and command application order.
8. Decide which engine data should remain outside the ECS and be referenced by handles.

## Challenge

Implement a small ECS supporting entities, Position, and Velocity. Add and remove components, update matching entities, and reject stale entity handles.
