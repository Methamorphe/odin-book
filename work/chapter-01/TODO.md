# Chapter 01 TODO

## Level 1 — Guided build

- [ ] Define `Recommendation` and `Project_Evaluation`.
- [ ] Parse `evaluate` without putting parsing in `main`.
- [ ] Reject missing, malformed, and negative values explicitly.
- [ ] Print the score, recommendation, and reasons.

## Level 2 — Interactive shell

- [ ] Add a real input loop.
- [ ] Implement `compare`, `help`, `demo`, `reset`, `stats`, and `quit`.
- [ ] Make commands whitespace-tolerant and case-insensitive.
- [ ] Keep `demo` deterministic.

## Level 3 — Tests

- [ ] Valid evaluation.
- [ ] Empty input.
- [ ] Malformed number.
- [ ] Zero budgets.
- [ ] Full capacity.
- [ ] Two evaluations followed by compare.

## Level 4 — Instrumentation

- [ ] Count accepted and rejected commands.
- [ ] Track evaluations by recommendation class.
- [ ] Record peak stored evaluations.
- [ ] Explain constrained-capacity behavior in `OBSERVATIONS.md`.

## Level 5 — Persistent product

- [ ] Implement save/load with an explicit format version.
- [ ] Implement transcript replay.
- [ ] Make `verify` recompute every score and classification.
- [ ] Add a corrupt-file test and a deliberately broken-invariant test.
