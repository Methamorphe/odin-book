# Chapter 47 — Profiling and Optimization

[← Chapter 46: Editor](46-editor.md) · [Exercises](../exercises/47-profiling-optimization.md) · [Chapter 48: Packaging a Small Game →](48-packaging-small-game.md)

Optimization is the process of meeting explicit budgets with evidence. The capstone should be profiled as a complete application because subsystem microbenchmarks do not reveal synchronization, contention, data movement, or frame pacing.

## 47.1 Define budgets

Create budgets before tuning:

- total frame time at the target refresh rate;
- simulation time;
- render submission time;
- GPU time;
- audio callback time;
- startup time;
- peak memory;
- asset streaming bandwidth;
- package size.

Budgets turn “fast” into a verifiable requirement.

## 47.2 Instrumentation layers

Use several levels:

- frame and subsystem timers always available in development;
- scoped CPU zones for functions and jobs;
- counters for queue depth, allocations, cache misses where available, and resource counts;
- GPU timestamp queries per pass;
- memory high-water marks by allocator or subsystem;
- offline traces for long captures.

Instrumentation should have bounded overhead and compile-time controls.

## 47.3 Frame pacing

Average FPS hides stutter. Record frame-time distributions, percentiles, worst frames, simulation-step count, present wait time, and missed deadlines. Correlate spikes across CPU, GPU, I/O, and operating-system events.

## 47.4 Allocation audit

Tag allocators by lifetime and subsystem. During steady-state gameplay, unexpected general-purpose allocations should be visible. Replace repeated allocations with arenas, pools, retained capacity, or frame-local buffers only after measuring.

## 47.5 Data access

Profile hot loops and inspect their data:

- remove unnecessary indirection;
- compact active sets;
- split cold fields;
- batch work by component or material;
- reduce repeated map lookups;
- precompute stable transforms or keys;
- use SIMD only after layout and algorithm are suitable.

Algorithmic and layout changes usually outperform instruction-level tricks.

## 47.6 Job-system tuning

Measure useful work, queueing, wakeup, synchronization, and idle time. Too-small jobs spend more time scheduling than executing; too-large jobs reduce parallelism. Avoid false sharing in counters and output buffers.

## 47.7 Renderer analysis

Separate CPU and GPU bottlenecks. CPU symptoms include command-building cost, descriptor churn, driver overhead, and excessive synchronization. GPU symptoms include bandwidth, overdraw, shader cost, occupancy, and render-target pressure.

Reducing draw calls is not automatically useful when the GPU is limited elsewhere.

## 47.8 Asset and I/O analysis

Measure file-open count, bytes read, decompression time, decode time, upload latency, and cache hit rate. Batch small reads where practical and keep runtime artifacts contiguous and validation-friendly.

## 47.9 Regression tests

Record representative scenes and automate budgets with tolerance. A performance test should control build mode, hardware class where possible, warmup, sample count, and background workload. CI can enforce deterministic counts and coarse timing, while dedicated machines handle strict performance gates.

## 47.10 Optimization workflow

1. reproduce the issue;
2. capture a representative trace;
3. identify the dominant cost;
4. form one hypothesis;
5. change one relevant factor;
6. measure again;
7. verify correctness and memory use;
8. retain or revert the change;
9. document the result.

Do not accumulate speculative tweaks.

## 47.11 Release validation

Profile release builds with development instrumentation where possible. Debug validation can distort results, but fully stripped releases can hide causes. Test startup, gameplay, editor-off packaging, slow storage, high-DPI displays, and integrated GPUs if supported.

## 47.12 Common mistakes

- optimizing before defining a target;
- relying on average FPS;
- profiling only debug builds;
- tuning code that is not on the critical path;
- hiding allocations instead of removing lifetime confusion;
- parallelizing work smaller than scheduler overhead;
- claiming GPU optimization from CPU-only measurements;
- keeping changes without before-and-after evidence.

## 47.13 Chapter checklist

You should have budgets, CPU and GPU instrumentation, frame-time distributions, allocator metrics, representative captures, a disciplined optimization loop, regression scenes, and release-build validation.

## References

- [Tracy Profiler](https://github.com/wolfpld/tracy)
- [RenderDoc](https://renderdoc.org/)
- [Google Benchmark methodology notes](https://github.com/google/benchmark)