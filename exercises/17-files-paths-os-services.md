# Chapter 17 Exercises — Files, Paths, and OS Services

[← Chapter](../book/17-files-paths-os-services.md) · [Solutions](../solutions/17-files-paths-os-services.md)

## Exercise 1 — Resource lifetime

Write a procedure that opens a text file, counts its bytes, and guarantees that the file is closed on every return path.

## Exercise 2 — Bounded read

Implement `read_bounded(path, maximum_size)` that rejects a file larger than the configured limit. Explain the race between metadata inspection and reading, then propose an incremental variant.

## Exercise 3 — Path construction

Build these paths using path utilities rather than string concatenation:

- `assets/textures/terrain/grass.png`
- `cache/shaders/basic.bin`

Extract each extension and base name.

## Exercise 4 — Safe project-relative path

Design validation rules for a command-line argument that must identify a file below a project root. Address absolute paths, `..`, symbolic links, and race conditions.

## Exercise 5 — Deterministic manifest

Enumerate a directory, retain only `.odin` files, sort them, and print one path per line. Explain why sorting is required.

## Exercise 6 — Atomic save

Describe and implement the high-level steps for replacing `save.dat` using a temporary file in the same directory.

## Exercise 7 — Typed configuration

Convert raw environment variables and arguments into:

```odin
Config :: struct {
    input:   string,
    output:  string,
    jobs:    int,
    verbose: bool,
}
```

Reject missing paths and job counts outside `1..64`.

## Challenge — Recursive asset scanner

Create an asset scanner that recursively walks a root directory, skips hidden directories, sorts output deterministically, reports permission failures, and never follows symbolic-link cycles.
