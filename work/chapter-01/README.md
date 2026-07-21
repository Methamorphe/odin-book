# Chapter 01 Workshop — Project Evaluator

This workshop turns Chapter 1 into a runnable decision tool.

## Start

```bash
odin run work/chapter-01
odin test work/chapter-01
```

## Commands to implement

- `evaluate <name> <latency-ms> <memory-mb> <ffi yes|no>`
- `compare <name-a> <name-b>`
- `help`, `demo`, `reset`, `stats`, `verify`, `quit`
- Level 5: `save <path>`, `load <path>`, `replay <path>`

## Suggested session

```text
evaluate editor 16 512 yes
evaluate invoicing 250 1024 no
compare editor invoicing
stats
verify
quit
```

Follow the five levels in `../../exercises/INTERACTIVE_WORKBOOK.md#chapter-1`. Read `TODO.md` before editing `main.odin`.
