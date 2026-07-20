# Contributing

Thank you for helping improve *The Odin Programming Book*.

## Editorial principles

Contributions should preserve the book's central goals:

1. **Teach mental models before syntax.** Explain what problem a feature solves and how to reason about it.
2. **Prefer primary sources.** Language claims should link to the official Odin documentation, package documentation, specification or compiler repository.
3. **Keep costs visible.** Allocation, ownership, mutation, failure and foreign boundaries should not be hidden in examples.
4. **Avoid ideology.** Present trade-offs. Do not describe a technique as universally superior without evidence.
5. **Use complete examples when practical.** A reader should know whether a code block is a complete program or an illustrative fragment.
6. **Separate exercises and solutions.** Do not reveal answers in the exercise file.
7. **Write for experienced programmers without assuming systems knowledge.** Universal basics may be concise; Odin-specific and low-level concepts should be developed carefully.

## Chapter structure

Technical chapters should normally contain:

- navigation links;
- learning objectives;
- conceptual explanation;
- compilable examples;
- design notes;
- common mistakes;
- a chapter summary;
- primary-source references;
- a matching exercise file;
- a matching solution file.

## Style

- Use American English.
- Address the reader directly when giving instructions.
- Prefer precise, concrete sentences.
- Define specialist terminology on first use.
- Use sentence case for headings.
- Format language names and ordinary prose normally; format identifiers as code.
- Avoid unsupported performance claims.
- Avoid comparing languages as teams or identities.

## Odin code

- Use `odin` fenced code blocks.
- Format code consistently with the Odin toolchain.
- State when code intentionally omits production error handling.
- Prefer names that communicate the domain rather than single-letter placeholders.
- Keep examples focused on the concept being taught.
- Link to relevant package documentation for non-obvious APIs.

## Links

Use relative links for material inside the repository. External references should point to stable, authoritative sources where possible.

Before submitting, verify internal links from both the edited file and `SUMMARY.md`.

## Exercises

Exercises should progress through:

1. recall;
2. reasoning;
3. implementation;
4. design.

Solutions should explain reasoning and trade-offs, not merely provide final code.

## Proposed changes

For substantial changes, open an issue describing:

- the reader problem;
- the proposed chapter or revision;
- prerequisites;
- expected examples and exercises;
- official references that support the material.

Small corrections can be submitted directly.