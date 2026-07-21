# Chapter 19 — Assertions, Diagnostics, and Logging

[← Chapter 18: Serialization and Binary Layouts](18-serialization-binary-layouts.md) · [Exercises](../exercises/19-assertions-diagnostics-logging.md) · [Part III: Professional Odin →](20-testing-reproducible-builds.md)

A systems program must explain what went wrong without hiding the original failure. Assertions, diagnostics, and logs all support that goal, but they serve different audiences and must not be used interchangeably.

## 19.1 Three different tools

Use an **assertion** when a condition should be impossible if the program is correct.

Use a **diagnostic** when an operation can legitimately fail and the caller or user needs actionable context.

Use a **log event** when recording runtime behavior is useful for operations, debugging, auditing, or performance analysis.

Confusing these categories produces brittle software. User input is not an invariant, and a debug log is not a substitute for returning an error.

## 19.2 Assertions encode invariants

Assertions make internal assumptions executable:

```odin
assert(index >= 0)
assert(index < len(items))
```

Good assertion targets include:

- internal indexes already validated at a boundary;
- impossible enum states;
- data-structure invariants;
- allocator bookkeeping;
- lifecycle transitions controlled entirely by the program.

Do not assert on normal external failures:

```odin
// Wrong: the user may provide a missing file.
assert(file_exists(path))
```

Handle that condition and report it.

## 19.3 Preconditions and postconditions

A procedure contract can be expressed with assertions where violation indicates a programming defect:

```odin
normalize_weights :: proc(weights: []f32) {
    assert(len(weights) > 0)
    // ...
    assert(all_finite(weights))
}
```

Preconditions should be documented at public package boundaries. Assertions help catch violations during development but do not replace API documentation.

## 19.4 Defensive checks versus assertions

A defensive check handles a condition that may occur in a valid deployment:

```odin
if len(packet) > MAX_PACKET_SIZE {
    return .Packet_Too_Large
}
```

An assertion catches a broken internal promise:

```odin
assert(write_offset <= len(buffer))
```

A useful test is: **Can correct software encounter this condition because of the environment or untrusted input?** If yes, return or report an error instead of asserting.

## 19.5 Preserve error context

A low-level error such as `permission denied` becomes more useful when wrapped with operation context:

```text
failed to write cache manifest `build/cache/assets.bin`: permission denied
```

Good diagnostics answer:

- what operation failed;
- which resource was involved;
- what the underlying cause was;
- what the user can do next, when known.

Do not erase the original cause while adding context.

## 19.6 Separate machine errors from presentation

Library packages should return typed failures and relevant data. The application boundary decides how to present them.

```odin
Load_Error :: enum {
    None,
    Not_Found,
    Permission_Denied,
    Invalid_Format,
    Unsupported_Version,
}
```

This keeps reusable code independent from terminal formatting, localization, UI dialogs, or log policy.

## 19.7 Diagnostic structure

A mature diagnostic may contain:

```odin
Diagnostic :: struct {
    severity: Severity,
    code:     string,
    message:  string,
    path:     string,
    line:     int,
    column:   int,
}
```

Stable codes are useful for tests, tooling, and documentation. Human wording can evolve while `CFG-004` continues to identify the same failure category.

## 19.8 Severity levels

A small set of levels is usually enough:

- trace: very detailed execution flow;
- debug: developer-oriented state;
- info: meaningful normal operation;
- warning: unexpected but recoverable condition;
- error: an operation failed;
- fatal: the process cannot continue safely.

The difference between warning and error should be based on outcome, not emotion. If the requested operation failed, it is generally an error even if the process remains alive.

## 19.9 Structured logging

Structured logs encode fields rather than flattening everything into prose:

```text
event=asset_load_failed path=assets/tree.mesh error=invalid_version version=7
```

Useful fields include:

- timestamp;
- level;
- event name;
- subsystem;
- request, job, or correlation ID;
- resource identifiers;
- duration;
- error category.

Structured data can still be rendered as readable text locally.

## 19.10 Event names over prose parsing

A stable event name such as `asset_load_failed` is easier to query than relying on a changing English sentence.

Prefer:

```text
event=asset_load_failed path=... reason=...
```

rather than expecting monitoring tools to parse:

```text
Oops, loading the asset did not work for some reason.
```

## 19.11 Context propagation

Operations that span packages or threads need a way to correlate events. Pass a request or job context explicitly rather than relying on mutable global state.

```odin
Job_Context :: struct {
    job_id:     u64,
    subsystem:  string,
}
```

A logger can receive this context and attach common fields consistently.

## 19.12 Avoid secret leakage

Logs frequently outlive the process and may be shipped to external systems. Never log:

- passwords;
- access tokens;
- private keys;
- full authorization headers;
- sensitive personal data without a defined policy.

Redaction must happen before values reach generic formatting helpers. Marking fields as sensitive in the domain model is safer than relying on every call site to remember.

## 19.13 Sampling and volume

A log statement inside a hot loop can become a performance problem or generate enormous storage costs.

Control volume through:

- level filters;
- event sampling;
- aggregation counters;
- rate limiting;
- logging only state transitions;
- compile-time removal of selected debug events.

Measure logging overhead in performance-sensitive code.

## 19.14 Logging is not control flow

This is broken:

```odin
if err != nil {
    log_error("save failed")
}
return true
```

The caller is told the operation succeeded. A log does not propagate failure.

Return the failure first. Logging should occur at the layer that has enough context and owns the presentation policy, often once rather than at every stack level.

## 19.15 Avoid duplicate logging

If every layer logs and returns the same error, one failure produces many nearly identical events.

A practical policy is:

- low-level packages return typed errors;
- intermediate layers add context;
- the application boundary logs once;
- internal retries may log only when operationally useful.

## 19.16 Crash diagnostics

When a fatal invariant fails, useful crash information may include:

- assertion expression;
- source location;
- stack trace;
- build identifier;
- platform and architecture;
- recent bounded log events;
- relevant subsystem state.

Crash handling must avoid making the failure worse. Allocation, locking, and complex formatting may be unsafe after memory corruption or in a signal handler.

## 19.17 Metrics are not logs

Logs describe discrete events. Metrics aggregate numeric behavior such as:

- request count;
- failure rate;
- queue depth;
- allocation volume;
- frame duration.

Do not emit one log per frame merely to reconstruct a metric. Use an appropriate measurement system and log exceptional transitions.

## 19.18 Testing diagnostics

Tests should verify stable semantics rather than brittle full prose where possible:

```text
error.code == "CFG-004"
error.path == "settings.json"
```

Snapshot tests can still validate complete user-facing output, but core tests should focus on codes, severity, spans, and causes.

## 19.19 A minimal logger interface

```odin
Log_Level :: enum {
    Trace,
    Debug,
    Info,
    Warning,
    Error,
}

Logger :: struct {
    minimum_level: Log_Level,
}

log :: proc(logger: ^Logger, level: Log_Level, event, message: string) {
    if level < logger.minimum_level {
        return
    }
    fmt.printf("level=%v event=%s message=%q\n", level, event, message)
}
```

Real systems may add sinks, timestamps, structured fields, synchronization, and buffering. Keep the interface small so policy can evolve without infecting every package.

## 19.20 Worked example: report once at the boundary

```odin
package main

import "core:fmt"

Load_Error :: enum {
    None,
    Not_Found,
    Invalid_Format,
}

load_project :: proc(path: string) -> Load_Error {
    if path == "" {
        return .Not_Found
    }
    if path != "project.odp" {
        return .Invalid_Format
    }
    return .None
}

main :: proc() {
    path := "broken.project"
    err := load_project(path)
    if err != .None {
        fmt.eprintf("event=project_load_failed path=%q error=%v\n", path, err)
        return
    }
    fmt.println("project loaded")
}
```

The library-style procedure returns a typed result. The application boundary chooses the log event and includes the path.

## 19.21 Common mistakes

### Asserting on user input

External failures are expected possibilities and need normal error handling.

### Logging and then pretending success

Logs do not replace return values.

### Logging at every layer

Add context through errors and report once at the policy boundary.

### Using unstable prose as an API

Provide stable diagnostic codes or event names.

### Logging secrets

Redact before generic logging infrastructure receives the value.

### Enabling verbose logs in hot paths

Use filtering, aggregation, and sampling, then measure overhead.

### Treating logs as metrics

Choose the correct observability signal for the question.

## 19.22 Chapter checklist

You should now be able to:

- distinguish assertions, errors, diagnostics, and logs;
- encode internal invariants without crashing on valid external failures;
- preserve causes while adding context;
- return typed failures from reusable packages;
- design structured events with stable names;
- propagate correlation context explicitly;
- avoid duplicate reporting and secret leakage;
- test diagnostic semantics independently from presentation.

## Part II review

You have now covered the core systems-programming responsibilities of Odin:

- explicit memory and ownership;
- allocator policy;
- arenas, pools, and temporary lifetimes;
- file, path, and process boundaries;
- durable serialization contracts;
- assertions and operational diagnostics.

Part III turns these foundations into professional engineering workflows: testing, reproducible builds, profiling, foreign interfaces, concurrency, SIMD, reflection, and API design.

## References

- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin `core:log` package](https://pkg.odin-lang.org/core/log/)
- [Odin language overview](https://odin-lang.org/docs/overview/)
- [OpenTelemetry logs data model](https://opentelemetry.io/docs/specs/otel/logs/data-model/)
