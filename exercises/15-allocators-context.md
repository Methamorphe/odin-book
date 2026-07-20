# Chapter 15 Exercises — Allocators and Context

[← Chapter](../book/15-allocators-context.md) · [Solutions](../solutions/15-allocators-context.md)

1. Rewrite a procedure that allocates implicitly so it accepts an explicit allocator.
2. Design a `Document` type that stores the allocator required to destroy its nested dynamic data.
3. Explain why destroying through the current context allocator can be incorrect.
4. Identify which data may escape a temporary allocator scope.
5. Propose allocator boundaries for an editor containing projects, documents, assets, and per-frame UI data.
6. Specify the metrics a tracking allocator should collect to diagnose leaks and allocation hot spots.
