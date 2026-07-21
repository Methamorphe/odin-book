# Chapter 18 TODO

- [ ] Encode fields explicitly; never dump struct memory.
- [ ] Bounds-check every decode read.
- [ ] Test wrong magic, truncated header, oversized payload, unsupported version, checksum mismatch, round trip.
- [ ] Track bytes serialized/deserialized.
- [ ] Add v1-to-v2 migration.
- [ ] `verify`: encode-decode-encode produces identical bytes for one version.
