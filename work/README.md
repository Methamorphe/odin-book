# Interactive chapter workshops

This directory contains the runnable starting points for all 48 chapters.

Each `chapter-NN` directory now contains:

```text
chapter-NN/
├── main.odin          # compile-safe starting package
├── README.md          # chapter-specific mission and commands
├── TODO.md            # five-level implementation checklist
├── fixtures/
│   └── demo.txt       # deterministic transcript to replay
└── expected/
    └── demo.txt       # observable acceptance criteria
```

## Start a chapter

Run from the repository root:

```bash
odin run work/chapter-NN
odin test work/chapter-NN
```

Then read, in this order:

1. `book/NN-*.md` for the concept;
2. `work/chapter-NN/README.md` for the project mission;
3. `work/chapter-NN/TODO.md` for the five cumulative levels;
4. `exercises/INTERACTIVE_WORKBOOK.md` for the complete exercise contract;
5. `solutions/INTERACTIVE_SOLUTIONS.md` only after attempting the level.

## Definition of done

A completed workshop must support the chapter-specific commands plus:

```text
help
demo
reset
stats
verify
save <path>
load <path>
replay <path>
quit
```

The following session must be reproducible without editing source code:

```bash
odin test work/chapter-NN
cat work/chapter-NN/fixtures/demo.txt | odin run work/chapter-NN
```

Compare behavior against `expected/demo.txt`. Exact formatting may differ unless the chapter explicitly requires byte-for-byte output, but state transitions, counters, errors, checksums, and invariants must match.

## Important

The supplied `main.odin` files are intentionally small compile-safe starting points. The learner implements the chapter-specific parser, state, commands, tests, persistence, and replay by following `TODO.md`. The fixtures and expected files define the target behavior; they are not pre-completed solutions.
