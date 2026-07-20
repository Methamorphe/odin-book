# Chapter 2 Solutions — Installing Odin

[← Exercises](../exercises/02-installing-odin.md) · [Back to Chapter 2](../book/02-installing-odin.md)

## Solution 2.1

`odin version` proves only that the shell can locate and execute a compiler binary. `odin check .` proves parsing and type checking work for the package. `odin build .` additionally proves code generation and native linking work. `odin run .` proves that the produced program can execute in the current environment.

## Solution 2.2

Directory package:

```bash
odin run .
```

Single-file package:

```bash
odin run main.odin -file
```

Use directory packages for normal projects because every `.odin` file in the directory participates in the package. Use `-file` for isolated experiments.

## Solution 2.3

Inspect the effective path with the shell's path-printing facilities and locate every compiler candidate. On Unix-like systems, `which -a odin` is useful; on PowerShell, `Get-Command odin -All` reveals candidates. The first matching entry wins, so remove or reorder stale paths.

## Solution 2.4

A valid answer contains a `package main`, imports `core:fmt`, defines `main :: proc()`, and successfully runs the executable produced by `odin build .`. Windows normally produces an `.exe`; Unix-like systems typically produce a binary without that suffix.

## Solution 2.5

The compiler is authoritative because it defines accepted Odin syntax and semantics. Editor diagnostics are a productivity layer and may be stale, misconfigured, or connected to a different compiler installation.

## Solution 2.6

A strong runbook is platform-specific, uses official links, verifies both compilation and linking, and describes how to inspect `PATH`, install the native linker toolchain, and reconcile editor/compiler version mismatches.

## Challenge notes

The toolchain note should pin a known-working version or release family while documenting a deliberate update process: update, run checks and tests, review language changes, then commit the new version expectation.
