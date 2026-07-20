# The Odin Programming Book

> Learn Odin from first principles to production-grade native software, data-oriented systems, and game engine architecture.

This repository contains an open-source, project-driven book about the [Odin programming language](https://odin-lang.org/). It is written for developers who already understand general programming and want to learn systems programming without inheriting the full complexity of C++.

The goal is not merely to teach Odin syntax. The goal is to teach you how to **think in Odin**:

- explicit ownership and lifetime decisions;
- simple, inspectable control flow;
- data-oriented program design;
- deliberate use of memory and allocators;
- practical interoperability with C;
- performance guided by measurement rather than folklore.

## Start reading

1. [Preface](book/00-preface.md)
2. [Chapter 1 — Why Odin?](book/01-why-odin.md)
3. [Chapter 1 exercises](exercises/01-why-odin.md)
4. [Chapter 1 solutions](solutions/01-why-odin.md)

The complete planned navigation is available in [SUMMARY.md](SUMMARY.md).

## What this book will cover

The book is organized into six progressive parts:

1. **Foundations** — toolchain, syntax, procedures, packages, values, pointers and collections.
2. **Memory and systems programming** — allocators, arenas, context, errors, files and operating-system APIs.
3. **Professional Odin** — testing, debugging, profiling, C interoperability, concurrency and SIMD.
4. **Data-oriented design** — layouts, handles, pools, ECS architecture, cache behavior and job systems.
5. **Graphics and game technology** — windows, input, rendering, assets, scenes, audio and tools.
6. **Capstone engine** — a small but production-minded engine and editor built incrementally.

## Learning model

Every technical chapter follows the same structure:

- learning objectives;
- a mental model before syntax;
- small compilable examples;
- design rationale and trade-offs;
- common mistakes;
- exercises in increasing difficulty;
- separate solutions;
- references to primary sources.

Examples will live in `examples/`, while larger guided applications will live in `projects/`.

## External references

The book prioritizes primary sources and links to them throughout the chapters:

- [Odin official website](https://odin-lang.org/)
- [Odin language overview](https://odin-lang.org/docs/overview/)
- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin compiler repository](https://github.com/odin-lang/Odin)
- [Odin language specification](https://odin-lang.org/docs/spec/)

## Project status

The book is being written in public. Completed chapters are linked from [SUMMARY.md](SUMMARY.md); planned chapters are marked as forthcoming.

## License

Book prose and code licensing will be documented explicitly before the first tagged release. Until then, all rights are reserved by the repository owner.