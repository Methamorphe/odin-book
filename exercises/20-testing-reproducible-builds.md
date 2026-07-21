# Chapter 20 Exercises — Testing and Reproducible Builds

[← Back to Chapter 20](../book/20-testing-reproducible-builds.md) · [Solutions](../solutions/20-testing-reproducible-builds.md)

## Exercise 1 — First behavioral test

Write `is_even :: proc(value: int) -> bool` and three `@(test)` procedures covering zero, a positive even number, and a negative odd number.

## Exercise 2 — Table-driven parser cases

Create a table of decimal strings and expected integer results. Include valid, empty, signed, overflow, and trailing-character cases. Write one loop that reports which case failed.

## Exercise 3 — Remove nondeterminism

A test calls the real clock and expects a cache entry to expire after sleeping. Redesign the cache to accept a clock dependency and test expiration without waiting.

## Exercise 4 — Allocation failure

Design a test for a procedure that builds a dynamic array with an injected allocator. Explain what state must remain valid when allocation fails halfway through.

## Exercise 5 — Compatibility fixture

Define a small binary header format. Add a fixed byte fixture representing version 1 and test that the current decoder still reads it correctly.

## Exercise 6 — Build modes

Write documented commands for development, test, profiling, and release builds. State which mode keeps symbols, assertions, and optimization.

## Exercise 7 — Reproducibility audit

List every undeclared input that could change a build on another machine: compiler, linker, environment, generated files, native libraries, timestamps, or paths. Propose how to pin or remove each one.

## Exercise 8 — CI design

Draft a GitHub Actions job that installs one pinned Odin version, checks all example folders, runs tests, and builds one release artifact. Keep commands runnable locally.

## Challenge

Create a `test-support` package containing a fake clock, deterministic random source, temporary directory helper, and counting allocator. Use at least two helpers in a small package test suite.