# Chapter 15 TODO

- [ ] Implement a builder that owns and frees its buffer.
- [ ] Wrap the allocator with allocation/free/byte counters.
- [ ] Define allocator-switch policy while allocations are live.
- [ ] Test forced failure, empty append, growth, switch policy, balanced frees, reset.
- [ ] Persist builder text and selected policy.
- [ ] `verify`: live bytes = allocated bytes - freed bytes.
