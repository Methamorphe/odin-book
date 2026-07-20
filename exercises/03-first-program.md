# Chapter 3 Exercises — Your First Odin Program

[← Back to Chapter 3](../book/03-first-program.md) · [Solutions](../solutions/03-first-program.md)

## Exercise 3.1 — Hello, developer

Write a program that prints your name, primary programming language, and the reason you are learning Odin. Use both `fmt.println` and `fmt.printf`.

## Exercise 3.2 — Split a package across files

Create `main.odin` and `greeting.odin` in the same directory. Put a procedure named `build_greeting` in the second file and call it from `main` without importing the file.

Explain why no file-level import is required.

## Exercise 3.3 — Import alias

Import `core:fmt` under the alias `output` and print three lines. State one legitimate reason for an alias and one poor reason.

## Exercise 3.4 — Command-line reporter

Print every command-line argument with its index. Test the program with zero, one, and three user-supplied arguments.

## Exercise 3.5 — Read diagnostics

Create and repair each failure:

1. an unknown identifier;
2. a mismatched package name across two files;
3. a missing import;
4. a call to a nonexistent package procedure.

For each case, copy the first compiler diagnostic and describe the actual cause in one sentence.

## Exercise 3.6 — Package boundary

Move `greeting.odin` into a `greeting/` subdirectory. Turn it into a separate package and update `main` so the project compiles again.

## Challenge — Tiny environment inspector

Build a command-line program that prints:

- its executable arguments;
- the number of arguments;
- a friendly message when no user arguments were provided;
- a numbered list otherwise.

Keep the entry point short by moving reporting logic into another procedure.
