# Chapter 24 Exercises — Threads, Atomics, and Synchronization

[← Chapter](../book/24-threads-atomics-synchronization.md) · [Solutions](../solutions/24-threads-atomics-synchronization.md)

1. Mark the ownership of every field in a producer/consumer queue shared by one producer and four workers.
2. Find the race in a shared counter updated with ordinary `+=` from several threads.
3. Design a lock-order rule for two stores that occasionally need to be updated together.
4. Write the predicate loop for a worker waiting on an empty queue and a shutdown flag.
5. Choose relaxed, release, acquire, or sequentially consistent semantics for a published-ready flag and justify the pairing.
6. Redesign eight adjacent hot counters to reduce false sharing.
7. Define full-queue behavior for a bounded background logging queue.
8. Write a safe shutdown sequence for workers that may be blocked waiting for work.

## Challenge

Design a deterministic parallel transform pipeline. Workers process independent indexes, cancellation is cooperative, and final results are committed in stable order.