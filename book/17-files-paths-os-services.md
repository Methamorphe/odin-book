# Chapter 17 — Files, Paths, and Operating-System Services

[← Chapter 16: Arenas, Pools, and Temporary Memory](16-arenas-pools-temporary-memory.md) · [Exercises](../exercises/17-files-paths-os-services.md) · [Chapter 18: Serialization and Binary Layouts →](18-serialization-binary-layouts.md)

Systems programs eventually cross the boundary between process memory and the operating system. They read configuration, enumerate directories, create cache files, inspect environment variables, launch processes, and report platform errors.

Odin exposes these capabilities through its core library while keeping resource ownership explicit. This chapter develops a practical model for file and path handling without hiding failure or lifetime.

## 17.1 Files are resources

An opened file is an operating-system resource. It must be closed regardless of whether later work succeeds:

```odin
file, err := os.open("config.txt")
if err != nil {
    return
}
defer os.close(file)
```

The important pattern is not the exact API spelling. It is the sequence:

1. acquire the resource;
2. check the acquisition result;
3. immediately schedule cleanup;
4. perform the work.

This keeps cleanup next to ownership.

## 17.2 Whole-file reads

Reading an entire file is appropriate when the input is known to be reasonably small, such as a configuration file, shader source, or metadata document.

```odin
data, ok := os.read_entire_file("settings.json")
if !ok {
    fmt.eprintln("could not read settings.json")
    return
}
defer delete(data)
```

A whole-file helper is convenient, but it allocates enough memory for the complete file. Before using it on external input, decide on a maximum accepted size.

Whole-file reads are usually a poor fit for:

- multi-gigabyte assets;
- streams with unknown length;
- files processed incrementally;
- latency-sensitive pipelines where work can begin before the complete file arrives.

## 17.3 Incremental I/O

Incremental reading gives the program control over buffering and memory use:

```odin
buffer: [4096]byte
for {
    count, err := os.read(file, buffer[:])
    if count > 0 {
        consume(buffer[:count])
    }
    if err != nil || count == 0 {
        break
    }
}
```

Production code must distinguish end-of-file from an actual error according to the library API being used. Never treat every short read as a failure: operating systems may return fewer bytes than requested.

The same principle applies to writes. A write operation may complete partially, so reusable infrastructure should loop until all bytes are written or an error occurs.

## 17.4 Text is still bytes

A text file is a byte sequence interpreted according to an encoding and newline convention. UTF-8 is common, but do not assume every external file is valid UTF-8.

Questions to answer at the boundary include:

- Is a byte-order mark accepted?
- Are `\n` and `\r\n` both supported?
- Is invalid UTF-8 rejected or replaced?
- Is the file size bounded?
- Are embedded zero bytes legal?

Text parsing becomes safer when decoding policy is explicit.

## 17.5 Paths are not ordinary strings

Paths have platform semantics. Separators, roots, drive letters, case sensitivity, reserved names, and normalization differ between operating systems.

Prefer path utilities over manual concatenation:

```odin
path := filepath.join({"assets", "textures", "stone.png"})
```

Manual concatenation such as `base + "/" + name` spreads platform assumptions and makes duplicate separators or missing components easy to introduce.

Useful path operations include:

- joining components;
- extracting the directory or base name;
- finding an extension;
- cleaning redundant `.` components;
- resolving an absolute path;
- computing a relative path.

## 17.6 Lexical normalization is not security validation

Cleaning a path is usually lexical. It does not prove that the resulting path stays inside a trusted directory after symbolic links, mount points, or platform-specific aliases are resolved.

For untrusted paths, a safe design should:

1. define an allowed root;
2. reject absolute user input when only relative paths are expected;
3. join and normalize carefully;
4. resolve canonical paths when appropriate;
5. verify the final target remains under the allowed root;
6. consider race conditions between validation and opening.

This is particularly important for archive extraction, upload storage, and plugin systems.

## 17.7 Current working directory

Relative paths are interpreted from the current working directory, not from the source file or executable location.

That distinction often causes programs to work in an editor and fail when launched by:

- a service manager;
- a test runner;
- a desktop shortcut;
- another process;
- a packaged game launcher.

Robust programs define where assets and configuration are located. Common strategies include paths relative to the executable, explicit command-line options, environment variables, and platform-specific application directories.

## 17.8 Directory enumeration

Directory traversal should define whether it is shallow or recursive, what happens with symbolic links, and how errors are handled.

A resource indexer may need to:

- skip hidden or generated directories;
- filter by extension;
- sort results for determinism;
- avoid following cycles through links;
- continue after recoverable permission errors;
- preserve the original error context.

Operating-system enumeration order is not a stable ordering contract. Sort entries before producing reproducible manifests or tests.

## 17.9 File metadata

Metadata can expose size, modification time, permissions, and file kind. Metadata is a snapshot and may become stale immediately.

Do not use a separate existence check as proof that a later open will succeed:

```text
check existence
another process removes the file
open file
```

This is a time-of-check/time-of-use race. Prefer attempting the real operation and handling its result.

## 17.10 Atomic replacement

Configuration, save-game, and cache writers should avoid leaving a partially written target after a crash.

A common strategy is:

1. create a temporary file in the same directory;
2. write the complete new contents;
3. flush when durability requires it;
4. close the file;
5. rename or replace the target atomically when supported.

Using the same directory matters because renames across filesystems may not be atomic.

Atomic replacement protects against partial content, but durable storage may require additional filesystem-specific synchronization. Define the durability level your application actually needs.

## 17.11 Environment variables

Environment variables are useful for deployment-specific configuration and secrets injected by process managers.

Treat them as untrusted text:

- missing values must have a policy;
- numbers require validated parsing;
- paths require path validation;
- secrets must not be printed in logs;
- empty and missing may have different meanings.

Capture configuration near process startup rather than reading arbitrary environment state throughout the program.

## 17.12 Command-line arguments

Command-line parsing should separate transport from validated configuration. Convert raw strings into a typed application configuration once:

```odin
Config :: struct {
    input_path: string,
    verbose:    bool,
    jobs:       int,
}
```

After parsing, the rest of the program should operate on `Config`, not repeatedly inspect raw arguments.

## 17.13 Processes and exit codes

Launching another process introduces more resources and failure modes:

- executable lookup;
- argument quoting;
- inherited environment;
- working directory;
- standard input and output pipes;
- process lifetime;
- exit code and termination signal.

Avoid constructing a shell command by concatenating untrusted strings. Prefer APIs that pass an executable and argument vector directly.

An exit code is part of the child process protocol. Decide which codes are expected and preserve stderr when diagnosing failures.

## 17.14 Standard streams

Standard input, output, and error have different roles:

- stdout carries normal machine- or user-facing output;
- stderr carries diagnostics;
- stdin carries piped or interactive input.

Command-line tools become composable when normal output remains parseable and diagnostics do not contaminate it.

## 17.15 Platform boundaries

Keep platform-specific operations behind a narrow package:

```text
app/
platform/
    files.odin
    process.odin
    paths.odin
```

The rest of the application should ask for domain operations such as `load_user_config` or `open_project_directory`, rather than spreading operating-system details everywhere.

This improves testing and makes future platform support less invasive.

## 17.16 Worked example: bounded configuration loading

```odin
package main

import "core:fmt"
import "core:os"

MAX_CONFIG_SIZE :: 64 * 1024

load_config :: proc(path: string) -> ([]byte, bool) {
    info, err := os.stat(path)
    if err != nil {
        return nil, false
    }
    if info.size > MAX_CONFIG_SIZE {
        return nil, false
    }

    data, ok := os.read_entire_file(path)
    if !ok {
        return nil, false
    }
    return data, true
}

main :: proc() {
    data, ok := load_config("settings.txt")
    if !ok {
        fmt.eprintln("failed to load settings")
        return
    }
    defer delete(data)

    fmt.printf("loaded %d bytes\n", len(data))
}
```

The size check is part of boundary validation. A production implementation should still account for races between metadata inspection and reading, potentially by enforcing the limit while reading incrementally.

## 17.17 Common mistakes

### Forgetting cleanup on an early return

Schedule `defer` immediately after successful acquisition.

### Assuming a single read or write transfers everything

Loop around incremental I/O until the requested work is complete or a meaningful terminal condition occurs.

### Building paths with string concatenation

Use path utilities and keep platform semantics centralized.

### Trusting normalized untrusted paths

Lexical cleanup alone does not prevent traversal through links or races.

### Treating directory order as deterministic

Sort when output stability matters.

### Logging secrets from environment variables

Redact sensitive configuration at the boundary.

## 17.18 Chapter checklist

You should now be able to:

- acquire and release file resources safely;
- choose between whole-file and incremental I/O;
- reason about partial reads and writes;
- use path utilities rather than manual separators;
- distinguish normalization from secure containment;
- design atomic replacement workflows;
- convert process inputs into typed configuration;
- isolate operating-system details behind a package boundary.

## References

- [Odin package documentation](https://pkg.odin-lang.org/)
- [Odin `core:os` package](https://pkg.odin-lang.org/core/os/)
- [Odin `core:path/filepath` package](https://pkg.odin-lang.org/core/path/filepath/)
- [The Open Group — File and directory functions](https://pubs.opengroup.org/onlinepubs/9699919799/)
