# Chapter 19 Solutions — Assertions, Diagnostics, and Logging

[← Exercises](../exercises/19-assertions-diagnostics-logging.md) · [Chapter](../book/19-assertions-diagnostics-logging.md)

## Exercise 1

A missing user file and an oversized network packet are normal external failures and require typed errors. A duplicate internal free-list slot and an impossible private state are violated invariants and are good assertion targets, while still considering crash containment at process boundaries.

## Exercise 2

Preserve the cause and add the operation and resource: `failed to write asset cache index 'cache/assets.index': permission denied`. A typed form should retain a `Write_Cache_Index` operation, path, and underlying OS error separately.

## Exercise 3

Use stable codes such as `CFG-002` and `FMT-007`, with structured path and source-position fields. Presentation code can later render these values for a terminal, editor, or JSON consumer.

## Exercise 4

The lowest layer returns the original typed failure. The middle layer adds domain context such as the asset ID or operation. The application boundary logs once because it owns user and operational presentation policy.

## Exercise 5

Example fields: `event=asset_import_failed`, `path`, `importer`, `duration_ms`, `error_code`, and `job_id`. Keep human prose optional and avoid parsing it for automation.

## Exercise 6

Never log tokens or authorization headers. Usernames may also be sensitive and should be omitted, hashed, or governed by policy. Retain a request or correlation ID, response code, event name, and safe failure category.

## Exercise 7

Replace per-entity frame logs with aggregated frame-duration metrics, counters for solver failures, sampled traces for selected entities, and logs only when an entity enters or leaves an abnormal state.

## Challenge

Store diagnostics as structured values, sort deterministic JSON by source location and stable code, separate rendering from collection, enforce a bounded maximum, and provide severity thresholds without deleting the original diagnostic data.
