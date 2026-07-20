# 1. Why Odin?

[Previous: Preface](00-preface.md) · [Summary](../SUMMARY.md) · [Exercises](../exercises/01-why-odin.md)

## Learning objectives

After this chapter, you should be able to:

- describe the class of problems Odin is designed to solve;
- explain the language's preference for explicitness and simplicity;
- distinguish language safety from engineering reliability;
- identify projects for which Odin is a strong or weak fit;
- recognize habits from object-oriented and managed languages that may not transfer well;
- state what "thinking in Odin" means at a high level.

## 1.1 A language for understandable native software

Odin is a general-purpose programming language with a deliberate focus on high-performance, native software. It provides direct access to memory, predictable data representation, pointers, custom allocation and straightforward C interoperability. At the same time, it tries to keep the language itself small enough that programmers can understand the code they are reading.

That combination matters.

Native software often needs to interact with operating systems, graphics APIs, audio devices, file formats, network protocols and hardware-oriented libraries. Those boundaries expose details that managed environments usually hide: byte order, alignment, ownership, allocation, calling conventions and lifetime.

A language can hide some of those details, but it cannot remove them from the underlying problem. Odin's approach is to expose them with relatively direct language features and conventional library APIs rather than burying them below a large abstraction system.

> **Mental model:** Odin is designed to help a programmer express a direct solution to a native-software problem without first constructing an elaborate language-level framework.

## 1.2 The cost of accumulated complexity

C and C++ remain foundational technologies for native software. They provide enormous ecosystems, mature compilers and access to nearly every platform API. Their strengths are real.

Their complexity is also real.

C is small, but many conveniences must be built manually or obtained through libraries and conventions. C++ has accumulated decades of features intended to support many programming styles and compatibility requirements. Templates, exceptions, inheritance, overload resolution, implicit conversions, move semantics, metaprogramming and multiple generations of library design all coexist.

This does not make C++ unusable. It means that understanding a C++ program often requires understanding both the program's domain and the particular subset of C++ chosen by its authors.

Odin takes a different path. It does not attempt to preserve source compatibility with C, and it does not try to support every paradigm equally. The language favors a smaller set of mechanisms that compose in predictable ways.

Examples of that preference include:

- procedures rather than a class-and-method object model;
- explicit pointer use rather than pervasive implicit references;
- tagged unions and enums rather than mandatory inheritance hierarchies;
- built-in arrays, slices, dynamic arrays and maps with clear distinctions;
- explicit allocator selection through ordinary program context;
- multiple return values and explicit error handling rather than exceptions;
- compile-time features that remain close to ordinary code.

The result is not automatically simple software. A programmer can create complexity in any language. The intended benefit is that Odin contributes less accidental complexity of its own.

## 1.3 Explicitness is not verbosity

The word *explicit* is often misunderstood. It does not mean spelling out every machine instruction or refusing all convenience. It means that important behavior should be visible where a reader needs to reason about it.

Consider memory allocation. In many environments, constructing an object silently allocates memory, and the runtime later decides when to reclaim it. This is productive for many applications. It becomes harder to reason about when allocations occur in a frame loop, an audio callback or a latency-sensitive service.

Odin allows APIs to use an allocator supplied through `context`, and it allows callers to replace that allocator for a scope. The code can remain convenient while allocation policy stays observable and controllable.

Similarly, `defer` is a convenience, but it is explicit. Cleanup is written next to acquisition and executes when the surrounding scope exits. A reader does not need to infer destructor behavior from a type hierarchy.

```odin
package main

import "core:os"

main :: proc() {
    file, err := os.open("notes.txt")
    if err != nil {
        return
    }
    defer os.close(file)

    // Use file here.
}
```

The exact APIs may evolve, but the pattern illustrates the design principle: acquisition and cleanup are visible in the same lexical region.

> **Design note:** Good explicitness reduces the distance between a decision and the code affected by that decision.

## 1.4 Simplicity is a constraint, not a missing feature list

A language with fewer features can look incomplete when evaluated feature by feature. Odin does not include classes, exceptions or a traditional method system. Those omissions are intentional constraints.

Constraints can improve design by removing entire categories of choices. Without classes and inheritance, the programmer tends to model data with structs and behavior with procedures. Composition becomes an ordinary data-layout decision rather than an object-model feature.

Suppose a game contains positions and velocities. A class-oriented design might begin with an `Entity` base class and subclasses that override an update method. Odin makes a data-first representation natural:

```odin
Position :: struct {
    x, y: f32,
}

Velocity :: struct {
    x, y: f32,
}

integrate :: proc(positions: []Position, velocities: []Velocity, dt: f32) {
    assert(len(positions) == len(velocities))

    for i in 0..<len(positions) {
        positions[i].x += velocities[i].x * dt
        positions[i].y += velocities[i].y * dt
    }
}
```

This is not always the best architecture, but it makes the transformation obvious: two collections enter, positions are updated, and the relationship between data layout and iteration is visible.

The broader lesson is not "inheritance is always bad." It is that a language can encourage programmers to begin with the data and operations actually required by the problem.

## 1.5 Safety, correctness and reliability

Modern language discussions often reduce safety to a binary label: safe or unsafe. Real systems are more nuanced.

Odin provides features that catch mistakes, including strong static types, bounds checks in normal array and slice access, distinct types, tagged unions, assertions and explicit conversions. It also permits operations that can be dangerous, such as pointer arithmetic, manual memory management and interaction with foreign code.

This reflects an important distinction:

- **Language safety** concerns what classes of invalid programs the compiler or runtime prevents.
- **Program correctness** concerns whether the implementation matches its specification.
- **Engineering reliability** concerns whether the system behaves acceptably under real inputs, failures and operational conditions.

A memory-safe language can still contain race conditions, deadlocks, incorrect financial calculations or destructive retry logic. A language with manual memory facilities can still support reliable systems when code is structured carefully, tested, instrumented and reviewed.

Odin does not promise to make invalid states impossible through an advanced type system. It instead gives programmers relatively simple mechanisms and expects them to use assertions, tests, validation, ownership conventions and appropriate allocation strategies.

> **Common mistake:** Treating Odin's simplicity as permission to skip engineering discipline. Explicit control increases responsibility; it does not replace tests or design.

## 1.6 Data-oriented design as a practical tool

Odin is frequently associated with data-oriented design. The phrase can sound abstract, but its basic question is concrete:

> What data does the program transform, and how should that data be arranged for those transformations?

Traditional object-oriented design often groups data and behavior around conceptual entities. Data-oriented design begins with access patterns, transformations and hardware costs. It may group values by how they are processed rather than by which conceptual object "owns" them.

For example, a particle system that updates one million positions may benefit from contiguous arrays of positions and velocities. A user-account administration tool with a few hundred records may gain nothing meaningful from such a layout.

The correct lesson is not that every program should become an ECS or a collection of structure-of-arrays containers. It is that layout and access patterns are part of program design, especially in performance-sensitive code.

Odin supports this style well because:

- arrays and slices are fundamental language concepts;
- structs have inspectable layouts;
- allocation policy can be controlled;
- pointers and raw memory are available where necessary;
- SIMD support and low-level numeric operations are accessible;
- procedures can operate directly over collections of data.

> **Measure it:** A data-oriented rewrite is not automatically faster. Profile before and after, and include maintenance cost in the evaluation.

## 1.7 Interoperability instead of isolation

A new systems language cannot afford to pretend the existing native ecosystem does not exist. Graphics, audio, compression, databases, operating-system APIs and scientific computing are dominated by C-compatible interfaces.

Odin is designed to call C libraries directly and to represent C-compatible data layouts. This allows an Odin program to use mature libraries without waiting for a native reimplementation of every dependency.

Interoperability has costs:

- foreign APIs may expose unsafe ownership rules;
- generated or handwritten bindings must be maintained;
- platform-specific build and linking details still matter;
- C conventions may be less ergonomic than native Odin APIs.

A common architecture is therefore to keep the foreign boundary narrow. A small package translates the external API into types and conventions used by the rest of the program.

```text
Application code
      |
Native Odin wrapper
      |
Generated or direct C bindings
      |
External C library
```

This isolates foreign ownership rules and makes replacement easier.

## 1.8 Where Odin is a strong fit

Odin is particularly attractive when several of the following are true:

- the program must compile to a native executable;
- predictable performance and data layout matter;
- the program integrates with C or operating-system APIs;
- custom allocation or lifetime control is useful;
- the team values a relatively small language surface;
- the domain benefits from batch processing or data-oriented layouts;
- developers are willing to own low-level engineering decisions.

Typical examples include:

- game engines and game tooling;
- renderers and visualization software;
- audio applications;
- simulation and scientific tools;
- editors and desktop utilities;
- emulators;
- command-line tools that need native dependencies;
- asset pipelines;
- experimental operating-system or compiler tooling.

This is a list of good candidates, not a restriction. Odin is general purpose, and real suitability depends on libraries, deployment constraints and team experience.

## 1.9 Where Odin may be the wrong choice

A language can be excellent and still be inappropriate for a project.

Odin may be a weak choice when:

- the project depends heavily on a mature framework available only in another ecosystem;
- rapid hiring from a broad mainstream talent pool is a primary constraint;
- the team cannot maintain foreign bindings or low-level infrastructure;
- deployment depends on a platform that the toolchain does not adequately support;
- memory safety enforced by the language is a non-negotiable organizational requirement;
- the application is conventional business software for which ecosystem productivity dominates runtime concerns.

For a standard CRUD web application, Go, Java, C#, TypeScript or another established ecosystem will often deliver more quickly. For a safety-critical component, organizational standards may require Rust, SPARK, Ada or restricted C/C++ practices.

Choosing Odin should be an engineering decision, not an identity.

## 1.10 Coming from other languages

### From C

You will recognize pointers, direct data representation and C interoperability. Odin adds richer built-in collections, namespaced packages, procedure overloading, multiple returns, `defer`, stronger type distinctions and allocator-aware conventions.

Do not write Odin as if it were C with different punctuation. Use slices instead of pointer-plus-length pairs where appropriate, use package scoping, and use the core library.

### From C++

You may initially search for constructors, destructors, classes, methods, templates and RAII types. Odin solves many of the same problems with explicit initialization procedures, `defer`, tagged unions, generic procedures and composition.

Avoid rebuilding a class hierarchy through structs full of function pointers unless dynamic dispatch is genuinely required.

### From Go

The syntax and directness may feel familiar. Odin provides more control over memory, layout, calling conventions and low-level operations. It does not provide Go's garbage collector or goroutine runtime as the default programming model.

Do not assume slices, strings or maps have identical semantics merely because the surface syntax looks related.

### From Rust

You will recognize the focus on native software and zero-cost abstractions, but Odin's philosophy differs substantially. It does not use a borrow checker to prove ownership relationships. Lifetimes are managed through conventions, allocation strategies, API contracts and testing.

Do not attempt to reproduce Rust's ownership model manually at every line. Instead, design lifetimes at subsystem boundaries and use arenas, scopes and handles where they simplify reasoning.

### From C#, Java or TypeScript

The largest transition is not syntax; it is resource reasoning. Values may live in stack storage, static storage, arenas, heaps or foreign memory. References do not automatically keep objects alive. Cleanup may be part of normal control flow.

Start by making lifetimes coarse and obvious. A whole level, request, frame or tool operation can often share an arena before you need fine-grained allocation.

## 1.11 What "thinking in Odin" means

At this stage, thinking in Odin can be summarized by six questions:

1. **What is the data?** Define the values and relationships required by the problem.
2. **How is it transformed?** Prefer procedures whose inputs, outputs and side effects are visible.
3. **Where does it live?** Decide lifetime and allocation at an appropriate architectural level.
4. **What crosses a boundary?** Isolate operating-system, library, thread and serialization boundaries.
5. **What can fail?** Represent expected failure explicitly and reserve assertions for violated invariants.
6. **What evidence supports the design?** Test correctness and measure performance.

These questions are more important than memorizing syntax. The remaining chapters provide the language tools needed to answer them precisely.

## 1.12 A first complete program

You do not need to understand every token yet. This small program previews several Odin ideas:

```odin
package main

import "core:fmt"

Rectangle :: struct {
    width:  f32,
    height: f32,
}

area :: proc(rectangle: Rectangle) -> f32 {
    return rectangle.width * rectangle.height
}

main :: proc() {
    rectangles := []Rectangle {
        {width = 4, height = 3},
        {width = 2, height = 8},
        {width = 5, height = 5},
    }

    total: f32
    for rectangle in rectangles {
        total += area(rectangle)
    }

    fmt.printf("Total area: %.2f\n", total)
}
```

Notice the overall shape:

- `package main` declares the package;
- imports are explicit;
- `Rectangle` is a plain struct;
- `area` is an ordinary procedure;
- the program processes a slice of values;
- there is no class hierarchy or hidden allocation requirement.

Later chapters will explain each construct and show how the representation changes when performance, mutation or lifetime requirements change.

## Chapter summary

- Odin targets understandable, high-performance native software.
- It favors a smaller, more orthogonal language over broad paradigm support.
- Explicitness means making important costs and decisions visible, not maximizing verbosity.
- The language provides safety checks but still permits low-level operations and manual lifetime control.
- Data-oriented design is a measurable technique, not a mandatory architecture.
- C interoperability allows Odin to participate in the existing native ecosystem.
- Odin is strongest when native execution, layout, performance and low-level integration matter.
- Thinking in Odin begins with data, transformations, lifetime, boundaries, failure and evidence.

## References

- [Odin official website](https://odin-lang.org/)
- [Odin language overview](https://odin-lang.org/docs/overview/)
- [Odin language specification](https://odin-lang.org/docs/spec/)
- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin compiler source](https://github.com/odin-lang/Odin)

---

[Previous: Preface](00-preface.md) · [Exercises](../exercises/01-why-odin.md) · [Back to summary](../SUMMARY.md)