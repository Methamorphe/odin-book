# Chapter 42 — Platform Layer

[← Chapter 41: Architecture and Constraints](41-architecture-constraints.md) · [Exercises](../exercises/42-platform-layer.md) · [Chapter 43: Renderer →](43-renderer.md)

The platform layer owns the unstable boundary between the engine and the operating system. It should expose a small, engine-oriented API while containing windowing, clocks, files, dynamic libraries, threads, and device-specific details.

## 42.1 Responsibilities

A practical platform package provides:

- application startup and shutdown;
- window creation, resize, focus, and close events;
- keyboard, mouse, controller, and text input;
- monotonic time and sleeping;
- paths for executable, user data, cache, and temporary files;
- file mapping or ordinary file access;
- dynamic-library loading for development;
- thread naming and CPU information;
- dialogs, clipboard, and cursor services when needed.

Do not put rendering policy, asset formats, or gameplay behavior in this layer.

## 42.2 Stable engine-facing types

Translate backend-specific values immediately:

```odin
Platform_Event :: union {
    Window_Closed,
    Window_Resized,
    Key_Event,
    Pointer_Event,
    Text_Event,
}
```

The rest of the engine should not depend on SDL, GLFW, Win32, Cocoa, or X11 constants. Translation localizes backend changes and keeps tests independent from native event loops.

## 42.3 Window lifetime

Treat a window as a stable handle. Store native pointers inside the platform implementation. Define whether resize dimensions are logical points, framebuffer pixels, or both. High-DPI systems frequently require both values.

A resize event should not directly rebuild renderer resources from inside a native callback. Record the event and process it at a safe point in the frame.

## 42.4 Input normalization

Separate:

- physical keys from text input;
- button state from edge transitions;
- pointer position from relative motion;
- controller identity from controller slot;
- window focus from application activity.

Build a frame snapshot after polling events. Fixed simulation steps can then consume a stable snapshot or an input command stream.

## 42.5 Time

Use a monotonic clock for frame timing and profiling. Wall-clock time can jump because of synchronization or user changes. Convert raw timestamps into one documented unit, preferably seconds as `f64` at public boundaries and integer ticks internally when precision matters.

## 42.6 Paths

Never assume the current working directory is the executable directory. Resolve:

- executable path;
- packaged data root;
- writable user-data directory;
- cache directory;
- temporary directory.

Normalize engine paths separately from operating-system paths. Asset IDs should not contain arbitrary platform separators.

## 42.7 File watching

Development builds may watch source assets or plugin binaries. Native watcher APIs differ and can coalesce, duplicate, or reorder events. Treat notifications as hints: debounce them, then re-stat or re-hash the target.

## 42.8 Dynamic libraries

Wrap loading, symbol lookup, and unloading behind explicit handles. Include the platform error text in diagnostics. On systems that lock loaded binaries, copy the candidate to a unique staging filename before loading.

## 42.9 Threads

The platform layer may expose logical CPU count, thread creation, joining, naming, affinity, and synchronization primitives. Prefer Odin core packages when they meet the requirement; use platform wrappers only where behavior genuinely differs.

## 42.10 Headless mode

A useful engine can start without a visible window for tests, asset compilation, server simulation, or CI. Keep command-line tools and headless runtime paths from requiring graphics initialization.

## 42.11 Testability

Provide deterministic seams:

- inject clock values;
- feed synthetic platform events;
- use temporary directories;
- substitute a fake clipboard;
- mock file-watcher notifications.

Do not attempt to fake the entire operating system. Test translation and policy separately from thin native bindings.

## 42.12 Common mistakes

- leaking backend enums into gameplay;
- assuming one coordinate scale;
- using wall-clock time for frame deltas;
- performing engine work inside native callbacks;
- relying on the current working directory;
- treating file-watch notifications as authoritative;
- making every package import the native window library.

## 42.13 Chapter checklist

You should be able to define a narrow platform API, normalize events and paths, manage high-DPI windows, use monotonic time, isolate dynamic libraries, support headless execution, and test translation logic.

## References

- [Odin core library](https://pkg.odin-lang.org/core/)
- [SDL documentation](https://wiki.libsdl.org/)
- [GLFW documentation](https://www.glfw.org/documentation.html)