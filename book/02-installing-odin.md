# Chapter 2 — Installing Odin

[← Chapter 1: Why Odin?](01-why-odin.md) · [Exercises](../exercises/02-installing-odin.md) · [Chapter 3: Your First Odin Program →](03-first-program.md)

Odin is distributed as a native compiler toolchain. There is no mandatory package manager, project manifest, virtual machine, or runtime service to configure before writing a program. A working setup needs three things:

1. the Odin compiler;
2. the platform linker and system development tools;
3. an editor or IDE with Odin language support.

This chapter establishes a reproducible local environment and explains what each command does instead of treating installation as a copy-and-paste ritual.

> **Version policy**
>
> Odin evolves continuously. Prefer a recent official release and record the compiler version used by a project. Commands in this book target the compiler available in 2026 and avoid relying on undocumented behavior.

## 2.1 Choose an installation strategy

The official project provides prebuilt archives for supported platforms and source-build instructions in the compiler repository. For learning, a prebuilt archive is usually the fastest path. Building from source is useful when you want to follow compiler development, test a patch, or contribute to Odin itself.

Primary references:

- [Official getting-started guide](https://odin-lang.org/docs/install/)
- [Official compiler repository](https://github.com/odin-lang/Odin)
- [Official releases](https://github.com/odin-lang/Odin/releases)

Avoid unofficial installers unless you understand how quickly they track upstream releases. A stale compiler can make valid examples appear broken.

## 2.2 Windows

### Prerequisites

Install a supported Microsoft C/C++ toolchain. The easiest option is **Visual Studio Build Tools** with the workload for desktop C++ development. Odin invokes the platform linker when producing native executables, so installing only an editor is not enough.

After downloading an official Odin archive:

1. extract it to a stable path, for example `C:\Tools\Odin`;
2. add that directory to the user or system `PATH`;
3. open a new terminal;
4. verify the installation:

```powershell
odin version
```

If `odin` is not recognized, inspect the effective path:

```powershell
$env:Path -split ';'
```

A common mistake is adding the archive's parent directory instead of the directory that actually contains `odin.exe`.

## 2.3 macOS

Install Apple's command-line developer tools first:

```bash
xcode-select --install
```

Then download and extract an official Odin build, place it somewhere stable, and add its directory to your shell path. One conventional layout is:

```bash
mkdir -p "$HOME/tools"
# Extract or move the Odin directory to $HOME/tools/odin
```

For `zsh`, add this to `~/.zshrc`:

```bash
export PATH="$HOME/tools/odin:$PATH"
```

Reload the shell and verify:

```bash
source ~/.zshrc
odin version
```

On Apple Silicon, use a build matching the architecture whenever one is provided. You can inspect the current machine with:

```bash
uname -m
```

## 2.4 Linux

A Linux system needs a C toolchain and linker. Package names vary by distribution.

Debian or Ubuntu systems commonly use:

```bash
sudo apt update
sudo apt install build-essential
```

Fedora-family systems commonly use:

```bash
sudo dnf group install "Development Tools"
```

After extracting the official archive, add the compiler directory to `PATH`:

```bash
export PATH="$HOME/tools/odin:$PATH"
```

Persist the line in the startup file used by your shell, then verify:

```bash
odin version
```

## 2.5 Verify more than the version command

`odin version` proves that the executable can be found. It does not prove that native linking works. Create a temporary directory containing `main.odin`:

```odin
package main

import "core:fmt"

main :: proc() {
    fmt.println("Odin toolchain ready")
}
```

Run the whole directory as a package:

```bash
odin run .
```

Expected output:

```text
Odin toolchain ready
```

Then check without keeping an executable:

```bash
odin check .
```

Finally build an executable:

```bash
odin build .
```

These commands serve different purposes:

| Command | Purpose |
| --- | --- |
| `odin check .` | Parse and type-check a package without producing a final executable. |
| `odin build .` | Compile and link a package. |
| `odin run .` | Build a package and immediately execute it. |
| `odin test .` | Build and execute procedures marked as tests. |

Use `odin help` and `odin help <command>` to inspect the options supported by your installed compiler rather than copying flags from an old article.

## 2.6 Odin builds packages, not loose files by default

The most important toolchain concept is that Odin normally compiles a **directory package**:

```bash
odin run .
```

Every `.odin` file in that directory belongs to the package and must declare the same package name. For tiny experiments, the `-file` flag treats one file as a complete package:

```bash
odin run main.odin -file
```

Use `-file` for isolated snippets. Prefer directory packages for real work because they match how Odin projects are organized.

## 2.7 Editor setup

A useful editor setup should provide:

- syntax highlighting;
- formatting;
- diagnostics;
- symbol navigation;
- completion powered by an Odin language server when available.

Visual Studio Code and compatible editors can use the community Odin extension and OLS, the Odin Language Server. Follow each project's current installation instructions because editor integrations evolve independently from the compiler:

- [OLS repository](https://github.com/DanielGavin/ols)
- [Odin VS Code extension](https://marketplace.visualstudio.com/items?itemName=danielgavin.ols)

Keep editor tooling subordinate to the compiler. When an editor diagnostic conflicts with `odin check`, the compiler is the authority.

## 2.8 Recommended project-local verification

Record the environment in a small script or contributor document. At minimum, contributors should be able to run:

```bash
odin version
odin check .
odin test .
```

For this book, examples are organized as independent directory packages. That makes examples executable, testable, and easier to keep compatible with future compiler releases.

## 2.9 Troubleshooting checklist

### The shell cannot find `odin`

- confirm that the compiler file exists;
- confirm the containing directory is in `PATH`;
- open a new terminal or reload the shell configuration;
- check for a typo or an old installation earlier in `PATH`.

### Compilation works but linking fails

- install the platform C/C++ development tools;
- verify that the target architecture matches the installed toolchain;
- on macOS, ensure the command-line tools are selected correctly;
- on Windows, repair or update the Visual Studio Build Tools installation.

### The editor reports errors but the compiler succeeds

- update the language server and extension;
- point the editor at the same Odin installation used by the terminal;
- restart the language server;
- trust `odin check` as the final result.

### An example from the internet no longer compiles

- compare its publication date with your compiler version;
- consult the official overview and package documentation;
- inspect release notes or repository history before assuming the language is broken.

## 2.10 What you should retain

A healthy Odin setup is deliberately small: compiler, native linker, editor. Learn the package-oriented commands early. `odin check .` should become a reflex, and your terminal should remain the source of truth even when using rich IDE tooling.

## Further reading

- [Getting Started with Odin](https://odin-lang.org/docs/install/)
- [Odin language overview](https://odin-lang.org/docs/overview/)
- [Odin compiler repository](https://github.com/odin-lang/Odin)
- [Official package documentation](https://pkg.odin-lang.org/)

---

[← Chapter 1: Why Odin?](01-why-odin.md) · [Exercises](../exercises/02-installing-odin.md) · [Chapter 3: Your First Odin Program →](03-first-program.md)
