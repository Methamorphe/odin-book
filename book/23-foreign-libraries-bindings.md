# Chapter 23 — Foreign Libraries and Bindings

[← Chapter 22: C Interoperability](22-c-interoperability.md) · [Exercises](../exercises/23-foreign-libraries-bindings.md) · [Chapter 24: Threads, Atomics, and Synchronization →](24-threads-atomics-synchronization.md)

A binding is not merely a translated header. A production binding must make library versions, platform differences, linkage, ownership, callbacks, and failure modes explicit.

## 23.1 Choose a binding strategy

Three common strategies are:

- direct declarations for a small stable C API;
- generated declarations for a large regular API;
- a handwritten C shim for macros, C++, unstable layouts, or platform differences.

Generation reduces typing but does not remove review. The output remains executable ABI documentation.

## 23.2 Repository layout

A maintainable integration separates concerns:

```text
vendor/library/          upstream source or revision metadata
bindings/library/raw/    direct ABI declarations
bindings/library/        safe Odin wrapper
examples/library/        minimal smoke programs
```

Application packages should import the safe wrapper, not raw declarations.

## 23.3 Version policy

Pin an exact upstream version or commit. Record:

- source origin;
- license;
- supported targets;
- required compile definitions;
- static or dynamic linkage;
- expected runtime files.

Bindings must evolve with the version they describe. A header from one release and binary from another can compile and still fail at runtime.

## 23.4 Static and dynamic linkage

Static linkage simplifies deployment but increases binary size and may change license obligations. Dynamic linkage allows shared updates but introduces search paths, runtime versioning, and missing-library failures.

Document the decision per platform. Do not rely on a developer machine’s globally installed library unless that is an explicit project requirement.

## 23.5 Platform selection

Centralize target-specific library names and flags:

```odin
when ODIN_OS == .Windows {
    // Windows library declaration
} else when ODIN_OS == .Linux {
    // Linux declaration
}
```

Keep platform branches close to the foreign boundary. Domain code should not repeatedly ask which library file exists.

## 23.6 Generated bindings

A generator should be reproducible. Store:

- generator version;
- input headers;
- target defines and include paths;
- post-processing rules;
- the command used to regenerate.

Generated code should carry a warning not to edit manually. Review diffs after regeneration, especially changed widths, enums, callbacks, and ownership annotations.

## 23.7 C++ libraries

C++ ABIs are complex and compiler-dependent. Prefer a stable `extern "C"` shim exposing opaque handles and plain data. The shim owns exceptions, templates, overloaded methods, and standard-library types.

Never allow a C++ exception to cross into Odin. Catch it in the shim and translate it into a result code or error object.

## 23.8 Resource wrappers

Pair foreign acquisition and release in one wrapper type:

```odin
Image :: struct {
    handle: rawptr,
}

image_destroy :: proc(image: ^Image) {
    if image.handle != nil {
        raw.image_destroy(image.handle)
        image.handle = nil
    }
}
```

Make cleanup idempotent where practical and invalidate handles after release.

## 23.9 Callback registry

If a C library stores callbacks, the wrapper often needs a registry that maps stable user-data handles to Odin state. Protect that registry if callbacks can arrive concurrently. Define deregistration behavior carefully so no callback observes freed state.

## 23.10 API normalization

A wrapper may normalize repetitive conventions:

- convert status codes into tagged errors;
- pair pointer and length into slices;
- expose enums as domain types;
- convert create/destroy into init/deinit procedures;
- isolate allocator callbacks;
- turn library-global state into an explicit context object.

Do not hide expensive copies, blocking calls, or retained pointers.

## 23.11 Optional symbols and feature detection

Some dynamic libraries expose symbols only in newer versions. Detect capabilities at initialization and store them in a feature table. Avoid scattered null checks around the application.

## 23.12 Packaging native artifacts

A release must include the right runtime files and search paths. Test from a clean machine or container, not only from the build directory. Verify architecture, debug/release variants, and transitive dependencies.

## 23.13 Licensing and provenance

Track license files and notices alongside vendored code. Generated bindings can still be derivative material. Record provenance so future maintainers know what may be redistributed.

## 23.14 Testing the integration

A foreign-library test matrix should include:

- load or link success;
- version query;
- one normal operation;
- one error path;
- repeated creation and destruction;
- callback delivery;
- unsupported-feature behavior;
- packaging smoke test.

## 23.15 Updating a binding

1. update the pinned upstream source;
2. regenerate or translate declarations;
3. review ABI-sensitive diffs;
4. rebuild every supported target;
5. run ownership and callback tests;
6. update wrapper behavior and migration notes;
7. verify packaged artifacts on clean systems.

## 23.16 Common mistakes

### Mixing raw and safe layers

If domain code can call raw functions freely, ownership guarantees are only suggestions.

### Depending on system-global installations

Builds become non-reproducible and deployment failures appear late.

### Wrapping everything before a use case exists

Start with the smallest coherent API and expand from tested needs.

### Ignoring transitive native dependencies

A library may load correctly on the build machine because another tool already installed its dependencies.

## 23.17 Chapter checklist

You should now be able to:

- choose direct, generated, or shim-based bindings;
- pin and document native dependencies;
- separate raw declarations from safe wrappers;
- package static or dynamic libraries intentionally;
- manage callbacks and optional capabilities;
- test and update bindings systematically.

## References

- [Odin packages collection](https://github.com/odin-lang/Odin/tree/master/vendor)
- [SemVer](https://semver.org/)
- [SPDX license identifiers](https://spdx.org/licenses/)

---

[Exercises](../exercises/23-foreign-libraries-bindings.md) · [Solutions](../solutions/23-foreign-libraries-bindings.md)