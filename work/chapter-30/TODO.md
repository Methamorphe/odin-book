# Chapter 30 TODO

- [ ] Implement free-list-backed fixed pool.
- [ ] Validate bounds, alive state, and generation on lookup.
- [ ] Increment generation on destroy/reuse.
- [ ] Test double destroy, stale lookup, reuse, full pool, invalid index, wrap policy.
- [ ] Track live/free/stale counts.
- [ ] `verify`: free + live = capacity and free slots are not alive.
