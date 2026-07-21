# Chapter 32 Exercises — Job Systems and Frame Pipelines

[← Chapter](../book/32-job-systems-frame-pipelines.md) · [Solutions →](../solutions/32-job-systems-frame-pipelines.md)

1. Draw a frame pipeline and mark dependencies and barriers.
2. Partition a 100,000-element update into balanced jobs.
3. Identify hidden global mutations that would make two jobs unsafe to overlap.
4. Design a simple shared-queue scheduler with worker shutdown.
5. Add dependency counters for a three-job graph.
6. Define a per-worker scratch-memory lifetime policy.
7. Design deterministic merging for parallel event buffers.
8. Choose profiling metrics that reveal scheduler overhead and critical-path stalls.

## Challenge

Implement a deterministic range scheduler simulation without threads: split work into jobs, process them in varying orders, and merge outputs stably. Then explain what synchronization a threaded version would require.
