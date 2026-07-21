# Chapter 21 Solutions — Debugging and Profiling

[← Exercises](../exercises/21-debugging-profiling.md) · [Chapter](../book/21-debugging-profiling.md)

1. A useful report names the failing command, exact input, Odin revision, OS/architecture, optimization mode, expected result, actual result, and smallest stack trace that identifies the fault.
2. Validate index range, generation equality, slot occupancy, and store lifetime at lookup boundaries. Keep recoverable stale-handle behavior separate from internal assertions.
3. Break on the update procedure with a condition such as `entity.id == 42`, inspect the caller and fields, then continue until the first invalid transition.
4. Use a watchpoint when one stable address is corrupted and the writer is unknown. It stops at the write instruction instead of producing high-volume logs after the fact.
5. Parse pre-created input inside the measured loop, consume a checksum outside optimization reach, and keep allocation or fixture creation outside unless those costs are being studied.
6. Sampling identifies broad CPU hotspots; instrumentation adds domain regions; a trace exposes ordering, waiting, and overlap. A frame spike often needs all three in that order.
7. Record allocation count, total and peak bytes, size histogram, lifetime buckets, allocator identity, and the stacks responsible for retained allocations.
8. Possible changes include reducing critical-section work, partitioning state, or replacing one global queue with per-worker queues. Validate with lock-wait time, throughput, tail latency, and correctness under stress.

## Challenge notes

Warm up before collecting samples, run enough iterations for stable distributions, report median and a high percentile, pin the build mode, and compare every optimized result with the scalar reference.