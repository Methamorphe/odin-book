# Chapter 24 — Threads, Atomics, and Synchronization

[← Chapter 23: Foreign Libraries and Bindings](23-foreign-libraries-bindings.md) · [Exercises](../exercises/24-threads-atomics-synchronization.md) · [Chapter 25: SIMD and Numerical Code →](25-simd-numerical-code.md)

Concurrency lets several tasks make progress during the same interval. Parallelism lets several tasks execute at the same time. Both introduce ordering, visibility, and lifetime problems that do not exist in single-threaded code.

## 24.1 Begin with ownership

Before choosing a mutex or atomic, decide which thread owns each piece of mutable state. The simplest concurrent designs minimize shared writable memory.

Prefer:

- immutable shared data;
- message passing;
- thread-local scratch memory;
- partitioned arrays where each worker owns a range;
- explicit handoff points.

Synchronization is easier when the data model already limits who may write.

## 24.2 Creating work

A thread needs a stable procedure and arguments whose lifetime outlives the thread. Never pass a pointer to stack state that returns before the worker finishes.

Conceptually:

```odin
worker :: proc(data: ^Work_Data) {
    // process data
}
```

Thread creation APIs differ by package and platform version; use Odin's threading packages rather than reproducing operating-system calls unless the platform layer requires it.

## 24.3 Joining and shutdown

Every created thread needs a shutdown policy. Joining proves that the worker has stopped before its state is released. Detached threads require another ownership mechanism and are rarely appropriate for ordinary application workers.

A clean shutdown sequence usually:

1. stops accepting new work;
2. signals cancellation;
3. wakes blocked workers;
4. joins all threads;
5. destroys queues and shared resources.

## 24.4 Data races

A data race occurs when threads access the same memory concurrently, at least one access writes, and synchronization does not order them. Data races can produce results that seem impossible in source order.

A race is not fixed by adding random delays or logging. Establish a happens-before relationship or remove the shared mutation.

## 24.5 Mutexes

A mutex protects an invariant spanning one or more fields:

```odin
lock(&state.mutex)
defer unlock(&state.mutex)

state.queue_count += 1
state.has_work = true
```

Keep critical sections small, but do not split one invariant across multiple lock regions merely to shorten them. Document which lock protects each field.

## 24.6 Lock ordering

Deadlocks often arise when two threads acquire the same locks in opposite order. Define a global order and follow it everywhere. Avoid calling unknown callbacks while holding a lock because the callback may re-enter the subsystem.

## 24.7 Condition variables and events

Busy-waiting wastes CPU. A condition variable lets a worker sleep until a predicate may have changed. Always re-check the predicate in a loop after waking because wakeups can be spurious or another thread may consume the work first.

```text
lock
while queue is empty and not shutting down:
    wait
consume work
unlock
```

The predicate, not the notification itself, is the source of truth.

## 24.8 Atomics

Atomics perform indivisible operations with explicit memory-order semantics. They are useful for counters, state flags, reference counts, and lock-free structures, but they do not automatically protect multi-field invariants.

If correctness requires `head`, `tail`, and `count` to agree, three atomic variables may be harder than one mutex-protected structure.

## 24.9 Memory ordering

Memory order defines which writes become visible across threads and in what relationship. The important conceptual levels are:

- relaxed: atomicity without broader ordering;
- acquire: later operations observe writes published before a matching release;
- release: earlier writes become visible to a matching acquire;
- sequentially consistent: a stronger global ordering model.

Use the strongest simple ordering until measurement proves it matters. Weak memory ordering is an advanced optimization, not a default style.

## 24.10 False sharing

Independent counters on the same cache line can cause heavy cache-coherence traffic. This is false sharing. Partition hot writable data, pad only after measurement, and consider per-thread counters merged at a synchronization point.

## 24.11 Work queues

A bounded queue gives backpressure. An unbounded producer can exhaust memory even when synchronization is correct. Define behavior when full:

- block;
- reject;
- drop low-priority work;
- grow within a hard limit.

Queue ownership and shutdown semantics belong in the API contract.

## 24.12 Job systems

A job system decomposes work into small tasks consumed by workers. Useful properties include:

- stable job storage;
- bounded queues;
- dependency counters;
- work stealing where justified;
- per-worker scratch allocators;
- frame or phase barriers;
- deterministic fallback for debugging.

Do not build a sophisticated scheduler before the workload demonstrates a need.

## 24.13 Cancellation

Cancellation should be cooperative. Workers check a shared token at safe points, release local resources, and return a meaningful status. Forcefully terminating threads can leave locks held and invariants broken.

## 24.14 Determinism

Parallel execution changes completion order. If output must be deterministic, separate parallel computation from ordered commit. For example, workers may fill independent result slots, then one thread applies results in stable index order.

## 24.15 Testing concurrency

Concurrency tests should repeat operations under varied worker counts and scheduling pressure. Test:

- zero and one worker;
- queue saturation;
- shutdown while idle and busy;
- repeated start/stop;
- cancellation;
- stale jobs;
- callbacks arriving during teardown.

A stress test can reveal a race but cannot prove its absence. Keep invariants and synchronization reasoning primary.

## 24.16 Common mistakes

### Using `volatile` as synchronization

Volatile access is not a substitute for atomic operations or locks.

### Holding a lock during blocking I/O

One slow operation can stall unrelated work and create lock convoys.

### Publishing partially initialized state

Construct an object fully before making its pointer visible to another thread.

### Freeing state before join

A shutdown flag does not prove the worker has stopped using memory.

## 24.17 Chapter checklist

You should now be able to:

- model concurrent ownership;
- identify data races and deadlock risks;
- use mutexes and condition predicates correctly;
- explain acquire/release ordering;
- design bounded queues and cooperative shutdown;
- preserve deterministic output when required.

## References

- [Odin core synchronization packages](https://pkg.odin-lang.org/core/)
- [C++ memory model reference](https://en.cppreference.com/w/cpp/atomic/memory_order)
- [The Art of Multiprocessor Programming](https://www.elsevier.com/books/the-art-of-multiprocessor-programming/herlihy/978-0-12-415950-1)

---

[Exercises](../exercises/24-threads-atomics-synchronization.md) · [Solutions](../solutions/24-threads-atomics-synchronization.md)