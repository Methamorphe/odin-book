# Chapter 2 Exercises — Installing Odin

[← Back to Chapter 2](../book/02-installing-odin.md) · [Solutions](../solutions/02-installing-odin.md)

## Exercise 2.1 — Verify the complete toolchain

Record the output of:

```bash
odin version
odin check .
odin build .
odin run .
```

Explain what each command proves about the environment. Why is `odin version` alone insufficient?

## Exercise 2.2 — Directory package versus single file

Create `main.odin` containing a minimal program. Run it first as a directory package, then as a single-file package.

Write down the two commands and explain when each workflow is appropriate.

## Exercise 2.3 — Diagnose a broken `PATH`

Temporarily invoke the compiler through its absolute path, then determine which shell configuration file should contain the permanent `PATH` change on your system.

Describe how you would detect an older Odin installation taking precedence.

## Exercise 2.4 — Prove that linking works

Create a program that imports `core:fmt`, builds an executable, and runs it manually. Locate the generated binary and identify its platform-specific file name.

## Exercise 2.5 — Editor independence

Introduce a syntax error. Compare the editor diagnostic with the result of `odin check .`. Write a short rule describing which tool is authoritative and why.

## Exercise 2.6 — Installation runbook

Write a one-page installation runbook for your operating system. It must include prerequisites, compiler installation, `PATH`, verification, editor setup, and three common failures.

## Challenge — Reproducible environment note

Add a `TOOLCHAIN.md` file to a sample repository containing:

- the tested Odin version;
- the operating system and architecture;
- verification commands;
- links to official installation sources;
- an update policy that does not blindly track every nightly compiler build.
