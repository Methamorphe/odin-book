# Chapter 16 TODO

- [ ] Reject allocation outside an active frame.
- [ ] Reset scratch memory at end-frame.
- [ ] Add fixed-block pool allocation/reuse.
- [ ] Test overflow, double begin, end without begin, pool exhaustion, reset reuse, escaped handle.
- [ ] Track peak bytes, occupancy, and resets.
- [ ] `verify`: scratch zero outside frame and free + used = pool capacity.
