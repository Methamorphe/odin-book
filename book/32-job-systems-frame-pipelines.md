# Chapter 32 — Job Systems and Frame Pipelines

[← Chapter 31: Entity-Component Systems](31-entity-component-systems.md) · [Exercises](../exercises/32-job-systems-frame-pipelines.md) · [Chapter 33: Asset Registries and Resource Lifetime →](33-asset-registries-resource-lifetime.md)

A job system distributes independent work across worker threads. A frame pipeline defines the dependency order that makes this work correct. The difficult part is rarely creating threads; it is expressing ownership, synchronization, and dependencies clearly.

## 32.1 Start with the frame graph

Before implementing a scheduler, write the major frame phases:

```text
poll input
  -> build commands
  -> simulate
  -> resolve collisions
  -> update animation
  -> extract render data
  -> submit rendering
```

Then identify which phases can overlap and which require a barrier.

## 32.2 Jobs are bounded units of work

A useful job has:

- explicit input data;
- explicit output data;
- bounded execution time;
- no hidden dependency on arbitrary global mutation;
- a defined completion condition.

Jobs should be large enough to amortize scheduling overhead and small enough to balance across workers.

## 32.3 Data parallelism

Many systems split a dense range into chunks:

```text
10,000 particles
  -> chunk 0: [0, 1024)
  -> chunk 1: [1024, 2048)
  -> ...
```

Each job writes only its assigned output range. This avoids locks in hot loops and reduces false sharing.

## 32.4 Task parallelism

Different independent subsystems can also overlap:

- audio command preparation;
- animation pose evaluation;
- visibility preparation;
- background asset decoding.

Task parallelism requires careful dependency declaration. Two tasks that both mutate the same registry are not independent.

## 32.5 Work queues

A basic scheduler may use:

- one shared queue protected by a mutex;
- a condition variable to wake workers;
- an atomic count of unfinished jobs;
- a barrier or wait operation.

More advanced systems use per-worker deques and work stealing, but a simple correct queue is preferable to a complex scheduler with unclear lifetime rules.

## 32.6 Work stealing

With work stealing, workers pop local jobs and steal from another worker when idle. This improves balancing for irregular workloads.

Costs include:

- more synchronization complexity;
- harder debugging;
- possible nondeterministic execution order;
- more care around shutdown and queue lifetime.

Implement it only after measuring imbalance in a simpler scheduler.

## 32.7 Dependency counters

A job can become runnable when its dependency count reaches zero:

```text
job C depends on A and B
A completes -> remaining = 1
B completes -> remaining = 0 -> enqueue C
```

Dependency storage must outlive all jobs that reference it. Cycles must be rejected or prevented by construction.

## 32.8 Barriers and phase boundaries

A barrier waits until all jobs in a group complete. Barriers are easy to reason about but can reduce parallelism.

Use them where phase semantics genuinely require all prior writes to finish. Do not add a global barrier after every small task.

## 32.9 Main-thread-only work

Some operations must remain on the main or render thread:

- window-system calls;
- selected graphics API operations;
- editor UI submission;
- platform event processing.

The scheduler should make thread-affinity constraints explicit rather than relying on convention.

## 32.10 Scratch memory

Jobs often need temporary memory. Good strategies include:

- per-worker scratch arenas;
- frame arenas reset after a barrier;
- caller-provided output slices;
- reusable buffers owned by the subsystem.

Never return a pointer into worker scratch memory beyond its valid phase.

## 32.11 Error handling

A background job cannot simply print an error and continue unnoticed. Define how failures propagate:

- store a typed result in job state;
- push a diagnostic record to a thread-safe queue;
- mark a resource failed;
- cancel dependent jobs when appropriate;
- surface the final error on the owning thread.

## 32.12 Cancellation and shutdown

Shutdown is a lifecycle problem. A robust sequence may be:

1. stop accepting external work;
2. signal cancellation;
3. allow or force queued jobs to finish;
4. wake sleeping workers;
5. join worker threads;
6. destroy queues and scratch memory.

Never destroy scheduler storage while workers can still access it.

## 32.13 Determinism

Parallel execution order is usually nondeterministic. Deterministic output may still be achieved by:

- partitioning writes by stable ranges;
- using per-job output buffers;
- merging in a stable order;
- avoiding shared floating-point reductions;
- assigning deterministic random streams.

Determinism should be designed, not assumed.

## 32.14 Profiling

A scheduler needs visibility:

- queue wait time;
- execution time;
- worker utilization;
- steal attempts;
- barrier wait time;
- job count and size distribution;
- critical path length.

A system can keep all workers busy while still being slow because the wrong work lies on the critical path.

## 32.15 Common mistakes

### Creating one job per tiny element

Scheduling overhead dominates useful work.

### Hiding shared mutation

Jobs that look independent may race through global services.

### Waiting immediately after scheduling

This turns asynchronous work back into synchronous work.

### Using worker scratch after the phase

Temporary memory lifetime must match the frame graph.

### Parallelizing before defining ownership

Concurrency magnifies unclear architecture.

## References

- [Odin Overview — Threads](https://odin-lang.org/docs/overview/#threads)
- [Intel Threading Building Blocks — Task Scheduler](https://oneapi-src.github.io/oneTBB/main/tbb_userguide/Task_Scheduler.html)
- [GDC — Destiny's Multithreaded Rendering Architecture](https://www.gdcvault.com/play/1022164/Multithreaded-Rendering-in-Destiny)
