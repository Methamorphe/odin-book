# Chapter 1 Exercises — Why Odin?

[Read the chapter](../book/01-why-odin.md) · [View solutions](../solutions/01-why-odin.md)

Try to answer the reasoning and design questions in writing. The purpose is to make your mental model explicit before later chapters add syntax and implementation detail.

## Recall

### 1.1 Language goals

In your own words, list three characteristics of software for which Odin is designed.

### 1.2 Explicitness

What does *explicitness* mean in the context of Odin? Explain why explicit code is not necessarily verbose code.

### 1.3 Deliberate omissions

Name three features common in other languages that Odin does not use as its primary model. What simpler mechanisms take their place?

### 1.4 Three dimensions

Explain the difference between:

1. language safety;
2. program correctness;
3. engineering reliability.

Give one example of a defect in each category.

### 1.5 Data-oriented design

Complete this sentence with a useful engineering definition:

> Data-oriented design begins by asking ...

## Reasoning

### 1.6 Choosing a language

For each project below, state whether Odin appears to be a strong candidate, a possible candidate or a weak candidate. Justify the answer with concrete constraints.

1. A cross-platform level editor that embeds a C physics library.
2. A conventional internal invoicing web application.
3. A real-time audio workstation plugin.
4. A safety-certified train-control component.
5. A command-line texture conversion pipeline.

There is not always one correct classification. The quality of the justification matters more than the label.

### 1.7 Visible costs

Consider an API that returns a newly allocated image buffer but does not document who owns the buffer or how it must be released.

Explain why this API is difficult to use reliably. Propose an interface contract that would make allocation and lifetime clearer, without writing Odin syntax yet.

### 1.8 Foreign boundaries

A program uses a C image-decoding library from fifty different files. Each file directly calls the C API and manually translates error codes.

Identify at least four maintenance or reliability problems this may create. Sketch a better package boundary.

### 1.9 Object-first versus data-first

A simulation contains 500,000 particles. Each particle has position, velocity, color and a virtual `update` operation.

Describe a data-oriented alternative. Explain which measurements you would collect before claiming that the alternative is better.

### 1.10 Assertions and expected failure

Classify each event as primarily an expected runtime failure or a violated programmer invariant:

1. A user supplies a path to a file that does not exist.
2. Two arrays that must have matching lengths reach an internal update procedure with different lengths.
3. A network request times out.
4. An enum value created by trusted internal code is outside its valid range.
5. A graphics device is unavailable on the user's machine.

Explain how the classification should affect error handling.

## Design

### 1.11 Lifetime strategy

You are designing a game level loader. Loading creates thousands of temporary strings and parse nodes, but only the final level representation must survive after loading.

Compare these strategies:

- individually allocate and free every temporary value;
- use one temporary arena for the load operation;
- keep all temporary values for the lifetime of the game.

Choose a default strategy and explain its benefits, risks and required invariants.

### 1.12 Small native tool

Choose a small tool you have previously built in another language. Examples include a log parser, image converter, deployment utility, data importer or editor plugin.

Write a one-page design note containing:

- the input data;
- the transformations;
- the output data;
- likely failure modes;
- external boundaries;
- expected lifetimes;
- what you would measure;
- why Odin would or would not be a sensible implementation language.

### 1.13 Architecture critique

A developer proposes the following rule:

> Every struct should have an associated table of function pointers so that the codebase remains extensible.

Critique the proposal. Describe situations in which dynamic dispatch is justified and situations in which it adds unnecessary indirection.

## Preview implementation

The following exercise uses syntax shown in the chapter. It is acceptable to return to it after reading the first syntax chapters.

### 1.14 Batch transformation

Write a program that:

1. defines a `Temperature_Sample` struct with a Celsius value;
2. stores at least five samples in a slice;
3. uses a procedure to convert Celsius to Fahrenheit;
4. prints every converted value;
5. computes the average Celsius value in one pass.

Then answer:

- Does the program allocate dynamically?
- Which values are copied into procedures?
- What would you change if each sample contained a large payload?

## Completion checklist

You are ready for the next chapter when you can:

- explain Odin's intended problem space without describing it merely as "a better C";
- distinguish explicit control from unnecessary verbosity;
- identify a foreign boundary and propose a wrapper around it;
- discuss data layout as a design decision;
- choose Odin—or reject it—for project-specific reasons.

---

[Read the chapter](../book/01-why-odin.md) · [View solutions](../solutions/01-why-odin.md)