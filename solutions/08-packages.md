# Chapter 8 Solutions — Packages

[← Exercises](../exercises/08-packages.md) · [Chapter →](../book/08-packages.md)

## 1. Calculator split

Use `expression` for tokens and parsing, `evaluation` for evaluating parsed expressions, and `app` for input/output and composition. `evaluation` may depend on `expression`; the reverse should not occur.

## 2. Compilation unit

All `.odin` files in one package directory contribute declarations to the same namespace. File boundaries organize reading; package boundaries organize dependencies.

## 3. Collection

```bash
odin build ./app -collection:project=./
```

Then import a local directory with `import "project:expression"`.

## 4. Replacing `utils`

Move unrelated code to owners. For example, path normalization belongs in `paths`, while numeric interpolation belongs in `math2d` or a domain-specific package.

## 5. Dependency graph

A reasonable direction is `app -> renderer`, `app -> assets`, `renderer -> platform`, `renderer -> math`, and `assets -> platform`. Avoid lower-level packages depending on `app`.

## 6. Breaking a cycle

Move orchestration to `game` or `app`, pass render data into `renderer`, or extract shared IDs and plain data into a lower-level package. The renderer should not own game rules.

## 7. Asset registry API

Expose initialization, shutdown, load, lookup, and release through distinct handles. Hide storage arrays, hash maps, and third-party decoder details.

## 8. Platform package

Define one platform-facing API and place operating-system implementations in dedicated files. The rest of the program imports only the platform package.

## 9. Composition root

`main` parses process configuration, creates long-lived systems, wires dependencies, runs the top-level command or loop, and shuts systems down in reverse order.

## 10. Game editor layout

One valid design uses `app`, `editor`, `game`, `renderer`, `assets`, `scene`, `platform`, and `math`. `app` composes everything; `editor` and `game` consume lower-level services; platform and math remain at the bottom. The exact graph matters less than clear ownership and one-way dependencies.
