# Chapter 47 — Solutions

[← Exercises](../exercises/47-profiling-optimization.md) · [Back to chapter](../book/47-profiling-optimization.md)

## 1. Budgets

For 60 Hz, start with 16.67 ms total and assign explicit subsystem budgets. Add peak-memory, startup, streaming, and package-size limits appropriate to the target hardware.

## 2. CPU instrumentation

Use nested scoped zones with stable names, timestamps, thread IDs, and frame IDs. Add counters for work volume so timing changes can be normalized.

## 3. Percentiles

Averages hide rare but visible spikes. Report median, p95, p99, worst frame, and missed-deadline count.

## 4. Allocation audit

Tag allocators, reset counters before the representative scene, record allocation count and bytes per frame, and fail development checks on unexpected steady-state allocations.

## 5. Layout

Compact active entities, split cold fields, iterate dense slices, batch by component or material, and replace repeated random map lookups with pre-resolved indexes.

## 6. Job experiment

Run the same workload with several chunk sizes, measuring useful work, scheduling overhead, idle time, synchronization, and variance.

## 7. CPU versus GPU

CPU-bound frames improve when submission work or synchronization changes; GPU-bound frames improve when render resolution, overdraw, bandwidth, or shader cost changes. Confirm with timestamps rather than inference alone.

## 8. Regression scene

Use fixed assets, camera, input script, build mode, warmup, frame count, and output counters. Store baseline ranges and hardware metadata.

## Challenge

The report should demonstrate causality. Keep the change only when the targeted metric improves without unacceptable regressions in correctness, memory, startup, or another budget.