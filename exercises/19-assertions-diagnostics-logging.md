# Chapter 19 Exercises — Assertions, Diagnostics, and Logging

[← Chapter](../book/19-assertions-diagnostics-logging.md) · [Solutions](../solutions/19-assertions-diagnostics-logging.md)

## Exercise 1 — Assertion or error?

Classify each condition and justify the choice:

- a user-selected file does not exist;
- an internal free-list contains the same slot twice;
- a network packet exceeds the protocol limit;
- a private state machine reaches an undocumented state.

## Exercise 2 — Add context

Turn the low-level error `permission denied` into an actionable diagnostic for writing `cache/assets.index` without discarding the cause.

## Exercise 3 — Typed diagnostics

Design a `Diagnostic` struct with severity, stable code, message, path, line, and column. Create examples for an invalid configuration key and an unsupported file version.

## Exercise 4 — Report once

Refactor a three-layer call chain where every layer logs the same failure. Decide which layer returns, which adds context, and which logs.

## Exercise 5 — Structured event

Define a structured event for a failed asset import. Include an event name, asset path, importer, duration, error code, and job ID.

## Exercise 6 — Secret audit

Review a hypothetical login logger that prints headers, username, token, and response code. Define what must be removed, redacted, or retained.

## Exercise 7 — Volume control

A physics loop emits 60 debug lines per entity per second. Propose a lower-volume observability design using metrics, sampling, and transition events.

## Challenge — Diagnostic sink

Implement a small diagnostic collector that stores typed diagnostics, filters by severity, renders terminal output, and can produce deterministic JSON suitable for CI tooling.
