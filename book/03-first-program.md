# Chapter 3 — Your First Odin Program

[← Chapter 2: Installing Odin](02-installing-odin.md) · [Exercises](../exercises/03-first-program.md) · [Chapter 4: Values, Variables and Constants →](04-values-variables-constants.md)

Your first Odin program should teach more than how to print a sentence. It should expose the language's basic compilation unit, imports, procedures, command-line workflow, and package model.

Create a directory named `hello-odin` and add a file named `main.odin`:

```odin
package main

import "core:fmt"

main :: proc() {
    fmt.println("Hello, Odin!")
}
```

Run it from that directory:

```bash
odin run .
```

The output is:

```text
Hello, Odin!
```

## 3.1 `package main`

Every Odin source file begins with a package declaration:

```odin
package main
```

A package is normally a directory containing one or more `.odin` files. Every Odin file in the same directory must declare the same package name.

The package named `main` is special when building an executable: it contains the program entry point. Library packages use descriptive names such as `math`, `assets`, or `network`.

Odin's directory-based package model has two practical consequences:

1. files in the same package share declarations without importing each other;
2. moving a file between directories can change package boundaries and dependencies.

This is intentionally simpler than systems that require a manifest entry for every source file.

## 3.2 Importing `core:fmt`

The line

```odin
import "core:fmt"
```

makes the official formatting package available under the name `fmt`.

`core:` is a **library collection** prefix. It tells the compiler to resolve the package from Odin's core library collection. The identifier after the final slash normally becomes the local package name.

You can provide an alias:

```odin
import formatting "core:fmt"
```

Then call:

```odin
formatting.println("Hello")
```

Aliases are useful when names collide or when a long package name would reduce readability. Do not alias packages merely to save one or two characters.

## 3.3 The `main` procedure

```odin
main :: proc() {
    fmt.println("Hello, Odin!")
}
```

Read this declaration from left to right:

- `main` is the declaration name;
- `::` declares a compile-time-known entity;
- `proc()` constructs a procedure with no parameters;
- the braces contain its body.

Procedures are values in Odin. A named procedure declaration associates a compile-time-known procedure value with a name.

Odin uses the term **procedure** instead of function because a procedure may return values, produce side effects, do both, or do neither.

## 3.4 Statements and semicolons

Inside the procedure body, this statement calls `println`:

```odin
fmt.println("Hello, Odin!")
```

Semicolons are usually inserted automatically at line boundaries. Idiomatic Odin code generally omits them. You still need to understand that statement termination exists because formatting a line incorrectly can change how the parser reads it.

Use one clear statement per line until you have a strong reason not to.

## 3.5 Printing values

`fmt.println` prints its arguments followed by a newline:

```odin
fmt.println("score:", 42)
```

For formatted output, use `fmt.printf`:

```odin
name := "Ada"
score := 42
fmt.printf("%s scored %d points\n", name, score)
```

Formatted output is useful, but do not let formatting syntax distract from the type system. The compiler can diagnose many mismatches, yet format strings still deserve careful review.

## 3.6 A slightly more useful first program

Replace the original body with:

```odin
package main

import "core:fmt"

main :: proc() {
    language := "Odin"
    year_started := 2016
    years := 2026 - year_started

    fmt.printf("%s has been evolving for about %d years.\n", language, years)
}
```

This introduces inferred variables with `:=`. The expression on the right determines the initial type.

The compiler sees:

- `language` as a string;
- `year_started` as an integer;
- `years` as an integer result.

You will study declarations in depth in the next chapter.

## 3.7 Multiple source files in one package

Create `message.odin` in the same directory:

```odin
package main

welcome_message :: proc(name: string) -> string {
    return "Welcome, " + name
}
```

Then update `main.odin`:

```odin
package main

import "core:fmt"

main :: proc() {
    fmt.println(welcome_message("Johann"))
}
```

Running `odin run .` compiles both files because both belong to the same directory package.

> **Note**
>
> String concatenation details and allocation behavior matter in production code. This example is intentionally small. Later chapters will examine strings and memory ownership carefully.

## 3.8 Compile, check, build, run

During development, use the narrowest command that answers your question.

### Type-check the package

```bash
odin check .
```

Use this frequently when editing. It catches syntax and type errors without launching the application.

### Build an executable

```bash
odin build .
```

Use this when you need the binary for inspection, packaging, or manual execution.

### Build and run

```bash
odin run .
```

Use this for fast feedback when the program's behavior matters.

### Run a single-file experiment

```bash
odin run scratch.odin -file
```

Use `-file` for throwaway experiments, not as the default structure for a growing project.

## 3.9 Reading compiler errors

Break the program deliberately:

```odin
fmt.println(unknown_name)
```

The compiler reports the file, line, column, and unresolved identifier. Develop the habit of reading errors from the first reported cause. Later messages may be consequences of the first mistake.

Another useful experiment is a type mismatch:

```odin
count: int = "three"
```

The diagnostic exposes Odin's refusal to hide incompatible conversions. This explicitness is a recurring theme throughout the language.

## 3.10 Comments

Single-line comments begin with `//`:

```odin
// Explain why, not what the syntax already says.
max_retries := 3
```

Block comments use `/*` and `*/` and may be nested:

```odin
/*
    Temporary investigation.
    /* Nested notes are valid. */
*/
```

Comments should preserve design context, invariants, or surprising constraints. A comment such as `// increment i` above `i += 1` adds noise.

## 3.11 A program with input arguments

Command-line arguments are available through the operating-system package. A minimal argument reporter looks like this:

```odin
package main

import "core:fmt"
import "core:os"

main :: proc() {
    fmt.println("argument count:", len(os.args))

    for argument, index in os.args {
        fmt.printf("[%d] %s\n", index, argument)
    }
}
```

Run it with arguments after `--` so they are passed to the program rather than interpreted as compiler options:

```bash
odin run . -- alpha beta
```

This example previews `len`, ranges, loops, and indexed iteration. Do not worry about every detail yet; focus on the shape of a complete program.

## 3.12 The first project layout

A small learning project can begin as:

```text
hello-odin/
├── main.odin
└── message.odin
```

As the program grows, introduce package directories by responsibility rather than by arbitrary file size:

```text
app/
├── main.odin
├── config/
│   └── config.odin
└── greeting/
    └── greeting.odin
```

Each subdirectory is a separate package and must be imported explicitly. Avoid creating many tiny packages before the boundaries are meaningful.

## 3.13 Common beginner mistakes

### Running the file without `-file`

This fails conceptually because Odin expects a directory package by default:

```bash
odin run main.odin
```

Use either:

```bash
odin run .
```

or:

```bash
odin run main.odin -file
```

### Mixing package names in one directory

All `.odin` files in a package directory must agree on the package name.

### Expecting methods on values

Odin separates data and procedures. You generally call `package.procedure(value)` rather than `value.method()`.

### Ignoring the first compiler error

Fix diagnostics from the top. One syntax error can create a cascade of misleading follow-up errors.

## 3.14 What you should retain

An Odin executable begins with a directory package named `main` and a `main :: proc()` entry point. Imports refer to packages, not individual files. The normal development loop is:

```text
edit → odin check . → odin run .
```

That loop is intentionally direct. There is little machinery between source code and native execution.

## Further reading

- [Official language overview](https://odin-lang.org/docs/overview/)
- [Official package documentation](https://pkg.odin-lang.org/)
- [`core:fmt` package documentation](https://pkg.odin-lang.org/core/fmt/)
- [`core:os` package documentation](https://pkg.odin-lang.org/core/os/)

---

[← Chapter 2: Installing Odin](02-installing-odin.md) · [Exercises](../exercises/03-first-program.md) · [Chapter 4: Values, Variables and Constants →](04-values-variables-constants.md)
