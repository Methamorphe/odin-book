# Preface

[Home](../README.md) · [Next: Why Odin?](01-why-odin.md)

## Who this book is for

This book is for programmers who already know how to build software and now want to understand native, performance-conscious programming through Odin.

You do not need prior experience with C or C++. You should, however, be comfortable with ordinary programming ideas such as variables, functions, loops, data structures and modules. When the book introduces lower-level concepts—addresses, alignment, allocators, data layout or foreign-function interfaces—it develops the required mental model before relying on terminology.

Experienced C, C++, Rust, Go, C# and Java developers are also part of the intended audience. Throughout the book, short comparison notes explain where familiar habits transfer cleanly and where they become misleading.

## What this book is trying to teach

A programming language is more than grammar. Learning syntax is easy; learning what a language makes natural is harder.

Odin encourages programs that are explicit, direct and organized around data. It offers low-level control without requiring the full historical and conceptual surface area of C++. It also avoids pretending that memory, lifetimes and operating-system boundaries do not exist.

The central objective of this book is therefore not:

> Memorize every Odin feature.

It is:

> Learn to make clear engineering decisions in Odin, understand their costs, and verify those costs with tools.

By the end of the book, you should be able to:

- design and organize a non-trivial Odin codebase;
- reason about values, addresses, lifetimes and allocation;
- build APIs that expose ownership and failure clearly;
- interoperate with C libraries without treating the boundary as magic;
- apply data-oriented techniques where they improve the program;
- profile CPU time, memory use and data movement;
- build a small native engine and editor from understandable components.

## How the material is organized

The book moves through six parts.

**Foundations** introduces the toolchain and the language's core constructs. These chapters are concise where the ideas are universal and detailed where Odin behaves differently from mainstream application languages.

**Memory and Systems Programming** develops a practical model of storage, allocation and operating-system interaction. This is where Odin starts to feel substantially different from managed languages.

**Professional Odin** covers the engineering practices required to maintain real programs: testing, diagnostics, profiling, interoperability, concurrency and API design.

**Data-Oriented Design** studies program structure through memory layout and transformations rather than through class hierarchies. It does not present data orientation as a religion; it presents it as a set of measurable techniques.

**Graphics and Game Technology** uses native application and rendering problems to combine the earlier material.

**The Capstone Engine** builds a compact engine and editor. The goal is not to compete with commercial engines. The goal is to make each subsystem small enough to understand, inspect and replace.

## How to use the exercises

Exercises are separated from chapter prose so that you can read without accidentally seeing solutions. They are grouped into four levels:

- **Recall** checks terminology and core rules.
- **Reasoning** asks you to predict or explain behavior.
- **Implementation** requires working Odin code.
- **Design** asks you to choose between valid approaches and defend the trade-off.

Do not skip the reasoning exercises merely because you are already an experienced developer. Systems bugs often come from an incorrect model, not from an inability to type code.

## Code policy

The examples aim to be:

- small enough to understand in isolation;
- complete enough to compile when presented as complete programs;
- explicit about omitted error handling or platform details;
- compatible with the documented Odin version for each tagged release of the book.

The repository will eventually use continuous integration to compile runnable examples. A code fragment used only to illustrate syntax will be clearly identified as a fragment.

## A note about a changing language

Odin continues to evolve. Language syntax, package names and library APIs can change. This book therefore treats official documentation and the compiler repository as primary sources, and tagged releases of the book will identify the Odin version they target.

When the book and a newer compiler disagree, consult:

- the [language overview](https://odin-lang.org/docs/overview/);
- the [language specification](https://odin-lang.org/docs/spec/);
- the [package documentation](https://pkg.odin-lang.org/);
- the [compiler repository](https://github.com/odin-lang/Odin).

## Conventions

Odin source appears in fenced blocks marked `odin`:

```odin
package main

import "core:fmt"

main :: proc() {
    fmt.println("Hello, Odin!")
}
```

Commands appear in shell blocks:

```sh
odin run .
```

The following callouts are used informally throughout the text:

- **Mental model** — the idea to retain after syntax is forgotten.
- **Design note** — why a feature or API is shaped a certain way.
- **Common mistake** — a plausible approach that creates bugs or confusion.
- **Measure it** — a claim that should be tested in the actual program.

## The promise of the book

This book will not claim that Odin makes hard engineering problems disappear. It will show how Odin makes many of those problems visible, gives you practical tools to address them, and stays out of the way when a direct solution is best.

---

[Home](../README.md) · [Next: Why Odin?](01-why-odin.md)