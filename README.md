# The Odin Programming Book

> Learn Odin from first principles to production-grade native software, data-oriented systems, graphics technology, and game engine architecture.

[![Odin CI](https://github.com/Methamorphe/odin-book/actions/workflows/odin-ci.yml/badge.svg)](https://github.com/Methamorphe/odin-book/actions/workflows/odin-ci.yml)

This repository contains a complete, open-source, project-driven book about the [Odin programming language](https://odin-lang.org/).

It is written for developers who already understand general programming and want to learn systems programming through explicit data, memory, ownership, and runtime architecture—without inheriting the full complexity of C++.

The goal is not merely to teach Odin syntax. The goal is to teach you how to **think in Odin**:

- make ownership and lifetime decisions explicit;
- prefer simple, inspectable control flow;
- design around data transformations and memory access;
- use allocators deliberately;
- interoperate safely with C and native libraries;
- build concurrent and performance-sensitive systems;
- measure before optimizing;
- carry a project from source code to a reproducible release.

## Book status

The main book is complete:

- **48 chapters** across 6 progressive parts;
- **5 appendices**;
- exercises for every chapter;
- separate solutions;
- standalone Odin examples;
- the evolving **Threadline Engine** capstone project;
- automated validation through GitHub Actions.

The full navigation is available in [SUMMARY.md](SUMMARY.md).

## Start reading

1. [Preface](book/00-preface.md)
2. [Chapter 1 — Why Odin?](book/01-why-odin.md)
3. [Complete table of contents](SUMMARY.md)
4. [Threadline Engine project](projects/engine/README.md)

A practical learning loop is:

1. read the chapter;
2. inspect and run its example in `examples/`;
3. complete the corresponding exercises in `exercises/`;
4. compare your approach with `solutions/`;
5. inspect how the same ideas shape `projects/engine/`.

## Contents

### Part I — Foundations

Toolchain, syntax, values, named types, procedures, control flow, packages, collections, structs, enums, unions, pointers, cleanup, and explicit errors.

### Part II — Memory and Systems Programming

The Odin memory model, allocators, arenas, pools, temporary memory, files, operating-system services, serialization, binary layouts, diagnostics, and logging.

### Part III — Professional Odin

Testing, reproducible builds, debugging, profiling, C interoperability, foreign libraries, threads, atomics, synchronization, SIMD, reflection, compile-time features, and API design.

### Part IV — Data-Oriented Design

Data transformations, cache-aware layouts, generational handles, object pools, entity-component systems, job systems, frame pipelines, asset registries, and resource lifetime.

### Part V — Graphics and Game Technology

Window and input architecture, rendering fundamentals, textures, meshes, materials, cameras, scenes, audio, event systems, immediate-mode tools, editor UI, hot reload, and plugin boundaries.

### Part VI — Capstone Engine

A production-minded engine project covering architecture, the platform layer, renderer, asset pipeline, runtime world, editor, profiling, optimization, and packaging a small game.

### Appendices

- Odin syntax reference;
- standard-library field guide;
- C, C++, Go, and Rust translation notes;
- complete exercise index;
- further reading.

## Threadline Engine

The project in [`projects/engine/`](projects/engine/README.md) is the longitudinal implementation for the book. Its first vertical slice includes an explicit application lifecycle, deterministic frame loop, generational entity handles, dense transform storage, a stable asset registry, renderer command extraction, frame statistics, and invariant tests.

```bash
odin run projects/engine
odin test projects/engine
```

The [project roadmap](projects/engine/ROADMAP.md) maps each architectural milestone to the corresponding book chapters, while [DESIGN.md](projects/engine/DESIGN.md) records the invariants that future iterations must preserve.

## Repository structure

```text
.
├── book/          # Preface, chapters 1–48, and appendices
├── examples/      # Standalone Odin example packages
├── exercises/     # Chapter exercises
├── solutions/     # Exercise solutions and design notes
├── projects/
│   └── engine/    # Threadline longitudinal capstone project
├── scripts/ci/    # CI validation scripts
├── SUMMARY.md     # Complete book navigation
└── README.md
```

## Running the examples

Install Odin using the official instructions, then run an example package from the repository root:

```bash
odin run examples/03-first-program
```

Validate a package without producing an executable:

```bash
odin check examples/03-first-program
```

Packages containing `@(test)` procedures can be tested with:

```bash
odin test examples/20-testing-reproducible-builds
```

The repository CI validates every example package and runs the Threadline Engine test suite.

## Design principles

The book consistently favors:

- explicit ownership over hidden lifetime rules;
- stable handles over uncontrolled long-lived pointers;
- caller-owned storage where practical;
- data-oriented iteration over object-heavy abstraction;
- narrow platform and foreign-library boundaries;
- deterministic inputs, builds, assets, and tests;
- profiling evidence over optimization folklore;
- small APIs with documented invariants and failure modes.

## Contributing

Corrections, clearer explanations, additional tests, portability improvements, and verified Odin syntax updates are welcome.

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. When changing an example or the capstone project, keep the relevant Odin CI checks green.

## Primary references

The chapters prioritize official and primary sources:

- [Odin official website](https://odin-lang.org/)
- [Odin language overview](https://odin-lang.org/docs/overview/)
- [Odin language specification](https://odin-lang.org/docs/spec/)
- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin compiler repository](https://github.com/odin-lang/Odin)

## License

Book prose and code licensing have not yet been formalized in a repository license file. Until that is done, all rights are reserved by the repository owner.