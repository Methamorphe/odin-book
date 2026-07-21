# Chapter 21 Exercises — Debugging and Profiling

[← Chapter](../book/21-debugging-profiling.md) · [Solutions](../solutions/21-debugging-profiling.md)

1. Write a minimal bug report for an out-of-bounds crash, including compiler, build flags, input, target, and stack frame.
2. Add assertions to a generational-handle lookup so the first broken invariant is visible.
3. Describe a debugger session using a conditional breakpoint that stops only for entity ID 42.
4. A value changes unexpectedly. Explain when a watchpoint is better than repeated logging.
5. Design a benchmark for a parser that separates setup, measured work, and result consumption.
6. Compare sampling, instrumentation, and a timeline trace for diagnosing a 16 ms frame spike.
7. Build a memory-profile checklist covering count, size distribution, peak live bytes, and retained lifetime.
8. Given a profile where 70% of wall time is lock waiting, propose three changes and the evidence needed to validate them.

## Challenge

Create a profiling harness that runs a workload over several input sizes, performs warm-up iterations, records median duration, and verifies the result against a reference implementation.