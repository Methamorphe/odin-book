# Chapter 23 Exercises — Foreign Libraries and Bindings

[← Chapter](../book/23-foreign-libraries-bindings.md) · [Solutions](../solutions/23-foreign-libraries-bindings.md)

1. Choose direct declarations, generation, or a C shim for five hypothetical libraries and justify each choice.
2. Propose a repository layout separating vendored source, raw bindings, safe wrappers, examples, and licenses.
3. Write a version manifest containing upstream revision, license, compile definitions, linkage mode, and supported targets.
4. Design a safe wrapper for a foreign image handle with idempotent destruction.
5. Describe a callback registry that remains safe during concurrent deregistration.
6. Define runtime capability detection for an optional dynamic-library symbol.
7. Create a clean-machine packaging checklist for Windows, Linux, and macOS.
8. Plan an upgrade from library version 2.3 to 3.0, including ABI review and migration testing.

## Challenge

Design a minimal `extern "C"` shim around a C++ audio class. Expose creation, destruction, buffer submission, status query, and error translation without leaking exceptions or STL types.