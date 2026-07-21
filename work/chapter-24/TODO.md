# Chapter 24 TODO

- [ ] Implement bounded work queue, worker lifecycle, shutdown, and join.
- [ ] Keep unsafe race demo opt-in and out of normal tests.
- [ ] Test zero workers, queue full, jobs > capacity, orderly shutdown, double shutdown, exact count.
- [ ] Track submitted/completed/rejected/pending jobs per worker.
- [ ] Add deterministic single-worker test mode.
- [ ] `verify`: submitted = completed + rejected + pending.
