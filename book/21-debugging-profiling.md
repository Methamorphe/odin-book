# Chapter 21 — Debugging and Profiling

[← Chapter 20: Testing and Reproducible Builds](20-testing-reproducible-builds.md) · [Exercises](../exercises/21-debugging-profiling.md) · [Chapter 22: C Interoperability →](22-c-interoperability.md)

Debugging explains why a program is wrong. Profiling explains where time, memory, or system resources are spent. Both require evidence rather than intuition.

## 21.1 Build for investigation

A useful debug build keeps symbols, assertions, and readable stack traces. A useful profiling build keeps symbols while using optimization close to production behavior. Measuring only an unoptimized debug build can point to costs that disappear in release mode.

Record the exact build command used for every investigation.

## 21.2 Reproduce before changing code

Reduce a failure to a stable sequence:

- exact input;
- target platform;
- compiler revision and flags;
- expected and actual behavior;
- earliest known failing revision;
- relevant logs or crash address.

A reproducible bug becomes an engineering problem. A vague bug remains a story.

## 21.3 Assertions and invariants

Assertions should fail near the first broken invariant, not much later when corrupted data is consumed. Add assertions at representation boundaries:

```odin
assert(index >= 0 && index < len(items))
assert(buffer.data != nil || len(buffer) == 0)
```

Do not convert recoverable user input errors into assertions. Assertions diagnose programmer mistakes.

## 21.4 Debuggers

Odin emits native programs that can be inspected with platform debuggers such as LLDB, GDB, or Visual Studio. Core operations are universal:

- set a breakpoint;
- run or attach;
- inspect stack frames;
- inspect locals and memory;
- step into, over, or out;
- watch a value or memory address;
- examine the crashing instruction.

Learn the debugger’s command-line interface even when using an IDE. It makes remote and CI crash investigation easier.

## 21.5 Conditional breakpoints and watchpoints

A breakpoint inside a hot loop may trigger millions of times. Use conditions such as a specific entity ID or frame number. A watchpoint is valuable when valid memory changes unexpectedly: it pauses at the instruction that wrote the location.

Watchpoints are limited hardware resources, so use them narrowly.

## 21.6 Reading a crash

Start from the faulting frame, then move outward:

1. identify the instruction and accessed address;
2. inspect the immediate inputs;
3. determine whether the pointer was null, stale, out of bounds, or misaligned;
4. trace ownership and mutation back to the first invalid transition;
5. add a regression test or invariant.

The crash site is often where corruption becomes visible, not where it began.

## 21.7 Logging without noise

Temporary logs can establish event order, thread identity, handles, sizes, and state transitions. Use structured fields and remove or downgrade exploratory logs after the issue is understood. High-volume unbounded logging can alter timing and hide concurrency bugs.

## 21.8 Differential debugging

Compare a working and failing case while changing one dimension at a time:

- input;
- compiler version;
- optimization level;
- operating system;
- thread count;
- allocator;
- feature flag.

Binary search through commits is often faster than reading every changed line.

## 21.9 Profiling starts with a question

Examples:

- Why did frame time rise from 8 ms to 14 ms?
- Which allocations happen during asset loading?
- Why does one request saturate a CPU core?
- Is time spent computing, waiting, or moving data?

A profile without a question often produces attractive graphs but weak decisions.

## 21.10 Sampling and instrumentation

A sampling profiler periodically observes call stacks. It has low overhead and is excellent for finding broad CPU hotspots.

Instrumentation measures explicit regions or events. It gives precise domain context but changes the program more and requires maintenance.

Use sampling first for unknown CPU costs, then instrument important pipelines for stable ongoing visibility.

## 21.11 Wall time, CPU time, and waiting

A slow operation may consume little CPU because it waits for disk, locks, network, GPU, or another thread. Distinguish:

- wall-clock duration;
- active CPU duration;
- blocked duration;
- scheduling delay;
- asynchronous completion time.

Optimizing computation does not help a lock convoy.

## 21.12 Representative workloads

Profile realistic data sizes and release-like conditions. Warm up caches and just-in-time external systems where relevant. Record input datasets so results can be repeated.

Microbenchmarks are useful for isolated primitives, but they do not replace application-level profiles.

## 21.13 Memory profiling

Track more than total bytes:

- allocation count;
- allocation size distribution;
- peak live memory;
- retained lifetime;
- fragmentation;
- allocator contention;
- temporary versus persistent allocations.

Reducing one million tiny allocations can matter more than reducing a single large startup allocation.

## 21.14 Benchmark discipline

A benchmark should report distributions, not one lucky duration. Use multiple iterations, avoid unrelated background work, and compare equivalent builds.

```odin
start := time.now()
for _ in 0..<iterations {
    consume(run_workload())
}
elapsed := time.since(start)
```

Prevent the compiler from eliminating work, and keep setup outside the measured region unless setup is the subject.

## 21.15 Flame graphs and traces

Flame graphs summarize sampled stacks: width represents accumulated samples, not chronological order. Timeline traces show events over time and are better for frame pipelines, jobs, I/O, and contention.

Do not infer causality from one visualization alone.

## 21.16 Optimization workflow

1. define the user-visible or system-visible problem;
2. capture a reproducible baseline;
3. profile the representative workload;
4. choose one dominant cost;
5. change the algorithm, layout, or synchronization strategy;
6. measure again;
7. verify correctness and secondary regressions;
8. keep the benchmark when it protects an important budget.

## 21.17 Common mistakes

### Optimizing from source appearance

Code that looks expensive may be irrelevant to total runtime.

### Measuring debug builds only

Debug checks and absent optimization distort hotspots.

### Timing with one iteration

Scheduler noise and cold caches dominate short measurements.

### Fixing symptoms instead of ownership

Repeated bounds crashes often indicate a lifetime or mutation design problem, not a missing check.

## 21.18 Chapter checklist

You should now be able to:

- prepare useful debug and profiling builds;
- investigate native crashes systematically;
- use breakpoints, conditional breakpoints, and watchpoints;
- distinguish sampling, instrumentation, traces, and benchmarks;
- analyze CPU, waiting, and allocation costs;
- run an evidence-driven optimization loop.

## References

- [LLDB documentation](https://lldb.llvm.org/use/tutorial.html)
- [GDB documentation](https://sourceware.org/gdb/documentation/)
- [Brendan Gregg’s performance resources](https://www.brendangregg.com/)

---

[Exercises](../exercises/21-debugging-profiling.md) · [Solutions](../solutions/21-debugging-profiling.md)