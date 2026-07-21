# Chapter 44 — Asset Pipeline

[← Chapter 43: Renderer](43-renderer.md) · [Exercises](../exercises/44-asset-pipeline.md) · [Chapter 45: Runtime World →](45-runtime-world.md)

The asset pipeline converts editable source files into validated runtime data. The engine should not parse every authoring format at startup. Build reproducible artifacts ahead of time and load a narrow, versioned representation at runtime.

## 44.1 Source, intermediate, and runtime data

Separate three concepts:

- source assets: PNG, WAV, glTF, JSON, shader source, scene authoring files;
- intermediate metadata: dependency graphs, import settings, hashes, diagnostics;
- runtime artifacts: compact binary blobs designed for fast validation and loading.

Source files are for people and tools. Runtime artifacts are for the engine.

## 44.2 Stable asset identity

Use a stable asset ID independent of absolute paths. A project-relative canonical path plus asset type can produce an ID, or the project database can assign one. Renames require explicit policy: preserve identity through metadata or treat the rename as delete-plus-create.

## 44.3 Importers

Each importer should:

1. validate source and settings;
2. enumerate dependencies;
3. decode source data;
4. transform into engine conventions;
5. optimize deterministically;
6. serialize a versioned artifact;
7. emit diagnostics and metadata.

Keep importer crashes and malformed input from corrupting the asset database.

## 44.4 Content hashing

Hash source bytes, importer version, import settings, target platform, and relevant dependency hashes. If the composite hash is unchanged and the artifact exists, skip rebuilding. Timestamps alone are not sufficient for reproducible caching.

## 44.5 Dependency graph

A material depends on textures and shaders; a scene depends on meshes, materials, scripts, and sub-scenes. Store forward and reverse edges. When an asset changes, rebuild the smallest correct closure and report cycles where the asset model forbids them.

## 44.6 Artifact headers

Every artifact should include:

- magic number;
- asset type;
- schema version;
- target platform or feature set;
- payload size;
- dependency count;
- integrity hash or checksum when useful.

Validate all sizes before allocation or pointer arithmetic.

## 44.7 Build database

The database maps stable IDs to source paths, importer settings, source hashes, dependency hashes, output artifact paths, and the latest diagnostics. It is derived data and should be rebuildable from source plus metadata.

## 44.8 Asynchronous runtime loading

Runtime loading usually has stages:

1. resolve asset ID;
2. read artifact bytes;
3. validate header;
4. decode CPU representation;
5. schedule GPU or audio upload;
6. publish a ready generation;
7. retire old generations when references are safe.

Keep I/O and decoding off critical frame threads.

## 44.9 Hot reimport

File watchers trigger re-hashing, not immediate replacement. Build the new artifact in isolation, validate it, then atomically publish a new registry generation. Preserve the old generation if import fails.

## 44.10 Determinism

Sort map-derived collections before serialization. Fix compression settings and floating-point transforms where possible. Record tool versions. Two clean builds from identical inputs should produce byte-identical artifacts unless documented otherwise.

## 44.11 Command-line tool

The importer should run without the editor:

```text
assetc build project.assetproj --target desktop
assetc inspect cache/mesh/abc123.asset
assetc clean --unused
```

This enables CI, release packaging, and headless servers.

## 44.12 Security and robustness

Treat source and artifact files as untrusted input. Bound dimensions, counts, recursion, decompressed size, and path traversal. Never trust offsets simply because an artifact came from the local cache.

## 44.13 Common mistakes

- loading authoring formats directly in release builds;
- keying assets by absolute paths;
- using timestamps as the only cache key;
- rebuilding all assets after any change;
- publishing failed imports;
- serializing unordered maps directly;
- coupling the importer to editor UI state.

## 44.14 Chapter checklist

You should have stable asset identity, importer contracts, content hashes, dependency tracking, versioned artifacts, a rebuildable database, asynchronous loading, hot-reimport rollback, and a headless build command.

## References

- [glTF specification](https://registry.khronos.org/glTF/)
- [Reproducible Builds](https://reproducible-builds.org/)
- [Odin core encoding packages](https://pkg.odin-lang.org/core/encoding/)