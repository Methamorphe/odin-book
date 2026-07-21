# Chapter 48 — Exercises

[← Chapter](../book/48-packaging-small-game.md) · [Solutions](../solutions/48-packaging-small-game.md)

1. List the exact contents of a release package.
2. Define embedded build identity fields.
3. Design read-only data and writable user path resolution.
4. Specify a deterministic asset manifest.
5. Write a ten-stage release pipeline.
6. Define save migration and rollback behavior.
7. Design a packaged smoke test.
8. Produce a release checklist covering licenses, symbols, signing, and checksums.

## Challenge

Design a cross-platform `release` command that builds assets and code, stages dependencies, smoke-tests outside the source tree, creates immutable archives, and emits a machine-readable manifest.