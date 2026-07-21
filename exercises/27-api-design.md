# Chapter 27 Exercises — API Design in Odin

[← Chapter](../book/27-api-design.md) · [Solutions](../solutions/27-api-design.md)

1. Redesign a procedure with six positional options into a descriptor with defaults and validation.
2. Document ownership for a procedure returning a slice into an internal cache that is invalidated by the next load.
3. Replace a public pointer to internal storage with a generational handle API.
4. Turn a `bool` result that conflates missing, invalid, and full into a domain error enum.
5. Design a caller-provided-buffer formatting procedure, including insufficient-capacity behavior.
6. Compare synchronous callbacks with an event queue for a resource loader that may complete on worker threads.
7. Define the public contract of a batch transform update: lengths, aliasing, allocation, thread safety, and complexity.
8. Review a package exposing globals, vendor structs, raw error codes, and undocumented allocations. Propose a migration path.

## Challenge

Design the public API for an asset registry. Include initialization, allocator policy, asynchronous requests, opaque handles, status queries, cancellation, error reporting, lifetime, reload behavior, and shutdown.