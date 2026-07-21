# Chapter 48 — Packaging a Small Game

[← Chapter 47: Profiling and Optimization](47-profiling-optimization.md) · [Exercises](../exercises/48-packaging-small-game.md) · [Appendix A: Odin Syntax Reference →](appendix-a-odin-syntax-reference.md)

The final chapter turns the capstone from a development checkout into a product another person can run. Packaging is part of architecture: paths, assets, configuration, licenses, crash reports, and update policy all affect runtime design.

## 48.1 Release contents

A release normally contains:

- the executable;
- required dynamic libraries;
- compiled runtime assets;
- default configuration;
- licenses and notices;
- optional symbols stored separately;
- a version manifest;
- platform metadata, icon, and signing information.

Do not ship source assets, editor caches, temporary files, or local absolute paths unless intentionally required.

## 48.2 Version identity

Embed a semantic product version, build number, source commit, target platform, build mode, asset schema version, and save-format version. Display this information in diagnostics and crash reports.

## 48.3 Data discovery

Resolve packaged data relative to the executable or an explicit install manifest. Writable settings and saves belong in the platform user-data directory. Never assume the process starts with the package directory as its working directory.

## 48.4 Asset manifest

Generate a deterministic manifest listing asset IDs, artifact paths, sizes, hashes, and optional dependency information. At startup, validate manifest compatibility before loading the first scene.

## 48.5 Build pipeline

A release command should perform:

1. clean or verify generated outputs;
2. compile assets for the target;
3. build the optimized executable;
4. run unit and integration tests;
5. stage runtime dependencies;
6. generate manifests and notices;
7. smoke-test the staged package;
8. archive or install it;
9. produce checksums;
10. optionally sign and notarize.

The process must be scriptable and repeatable.

## 48.6 Platform-specific packaging

Windows may require an application manifest, icon resources, redistributable runtime decisions, and code signing. macOS requires an application bundle and may require signing and notarization. Linux releases must document library expectations or ship a suitable bundle format.

Keep platform metadata outside gameplay packages.

## 48.7 Configuration

Separate immutable defaults from user overrides. Validate settings, retain unknown forward-compatible fields where useful, and recover from corruption by preserving the bad file before generating defaults.

Command-line flags should support diagnostics, data-root override, headless mode, safe mode, and log location.

## 48.8 Save compatibility

A release must define whether saves are forward-compatible, backward-compatible, or tied to a major version. Store versioned records and migrate through explicit steps. Never overwrite the only save before migration succeeds.

## 48.9 Crash and log handling

Write logs to a writable per-user directory with rotation and size bounds. Include build identity, platform, GPU, asset manifest version, and the last major state transition. Keep private user data and secrets out of reports.

Preserve symbol files separately so release addresses can be symbolicated.

## 48.10 Smoke tests

A packaged smoke test should launch from a directory unrelated to the source tree, load the initial scene, render several frames, exercise input or a scripted path, save settings, and exit cleanly. Run it against the staged package, not the development binary.

## 48.11 Distribution and updates

Publish immutable versioned artifacts with checksums. If updates are supported, download to a staging location, validate signature and hash, then replace files atomically or through a launcher. Keep rollback information for failed updates.

## 48.12 Final project review

Before declaring the project complete, verify:

- a clean machine can build or run it;
- CI validates all examples and tests;
- the game loop is playable from start to finish;
- release assets contain no development paths;
- startup and shutdown are clean;
- performance budgets are documented;
- licenses are included;
- known limitations are honest;
- the repository explains how to reproduce the release.

## 48.13 Common mistakes

- copying files manually for every release;
- loading assets from the source tree;
- writing saves beside the executable;
- omitting dependency licenses;
- deleting old saves before migration succeeds;
- testing only from the development working directory;
- stripping all diagnostics before release validation;
- publishing mutable artifacts under one version.

## 48.14 Completion

You now have the conceptual and practical pieces required to build Odin software from syntax to systems architecture, native tooling, data-oriented runtime design, graphics technology, and release packaging. The value of the capstone is not its feature count. It is the explicit chain from constraints to shipped behavior.

## References

- [Reproducible Builds](https://reproducible-builds.org/)
- [Semantic Versioning](https://semver.org/)
- [Apple code signing](https://developer.apple.com/support/code-signing/)
- [Microsoft code signing](https://learn.microsoft.com/windows-hardware/drivers/dashboard/code-signing-reqs)
