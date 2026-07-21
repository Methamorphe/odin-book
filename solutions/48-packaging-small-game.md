# Chapter 48 — Solutions

[← Exercises](../exercises/48-packaging-small-game.md) · [Back to chapter](../book/48-packaging-small-game.md)

## 1. Package contents

Ship the executable, required libraries, compiled assets, defaults, manifests, licenses, and platform metadata. Keep symbols separately and exclude source assets and caches.

## 2. Build identity

Embed product version, build number, source commit, target, build mode, asset schema, and save schema. Include them in logs and crash reports.

## 3. Paths

Resolve immutable data relative to the executable or install manifest. Resolve settings, saves, logs, and cache through platform user directories.

## 4. Asset manifest

Sort entries by stable asset ID and record type, relative artifact path, size, hash, and schema version. Validate compatibility at startup.

## 5. Pipeline

Build assets, compile release code, run tests, stage dependencies, generate notices and manifests, smoke-test, archive, checksum, sign, and publish.

## 6. Save migration

Copy or stage the old save, migrate into a candidate file, validate it, then atomically replace the active save. Preserve the original on failure.

## 7. Smoke test

Launch the staged executable from an unrelated working directory, load the initial scene, run scripted frames, save settings, verify outputs, and exit cleanly.

## 8. Checklist

Verify third-party notices, symbols, code signing or notarization, checksums, immutable version names, clean-machine behavior, and rollback artifacts.

## Challenge

The command should be non-interactive, target-aware, reproducible, and fail-fast. It emits both the package and a manifest containing hashes, versions, included files, and build provenance.