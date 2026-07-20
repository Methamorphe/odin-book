# Chapter 13 Exercises — Cleanup and Explicit Errors

[← Chapter](../book/13-defer-explicit-errors.md) · [Solutions](../solutions/13-defer-explicit-errors.md)

1. Open two resources and guarantee reverse-order cleanup with `defer`.
2. Define a `Parse_Error` enum for an integer parser and specify which errors callers can act upon.
3. Refactor duplicated cleanup branches into one ownership path.
4. Explain why a `defer` inside a long-running loop can retain resources too long.
5. Design a constructor that partially initializes three resources and safely rolls back on failure.
6. Separate recoverable input errors from violated internal invariants in a small command-line tool.
