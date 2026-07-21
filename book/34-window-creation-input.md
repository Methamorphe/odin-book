# Chapter 34 — Window Creation and Input

[← Chapter 33: Asset Registries and Resource Lifetime](33-asset-registries-resource-lifetime.md) · [Exercises](../exercises/34-window-creation-input.md) · [Chapter 35: Rendering Fundamentals →](35-rendering-fundamentals.md)

A game or graphical tool begins at the platform boundary. The application must create a native window, receive operating-system events, translate physical input into stable application concepts, and preserve a clean separation between platform code and the rest of the program.

## 34.1 The platform boundary

Keep native handles and backend-specific structures inside a small platform package. Gameplay, tools, and renderer code should depend on your own types:

```odin
Window_Handle :: distinct u32

Window_Desc :: struct {
    title: string,
    width: int,
    height: int,
    resizable: bool,
}
```

A narrow boundary makes it possible to replace SDL, GLFW, raylib, Win32, Cocoa, or another backend without rewriting the application.

## 34.2 Window lifetime

Window creation is a resource acquisition operation. A typical lifecycle is:

1. initialize the backend;
2. create the native window;
3. create graphics resources tied to it;
4. process events and render frames;
5. destroy graphics resources;
6. destroy the window;
7. shut down the backend.

Use `defer` where scope order matches lifetime order, but do not hide ownership. A window should have one clear owner.

## 34.3 The event pump

Operating systems deliver input and lifecycle notifications as events. Poll them once per frame and convert them into an engine-owned event form:

```odin
Event_Kind :: enum {
    None,
    Quit,
    Resize,
    Key_Down,
    Key_Up,
    Mouse_Move,
    Mouse_Button_Down,
    Mouse_Button_Up,
    Mouse_Wheel,
    Text_Input,
}
```

Do not leak backend key codes across the application. Translate them at the platform boundary.

## 34.4 State versus events

Input has two complementary representations:

- **events** describe transitions such as “key pressed this frame”;
- **state** describes persistent conditions such as “key currently held.”

A useful input snapshot stores both:

```odin
Button_State :: struct {
    down: bool,
    pressed: bool,
    released: bool,
}
```

At the start of each frame, clear transient fields. Event processing then updates the snapshot.

## 34.5 Physical input and actions

Gameplay should rarely ask whether a specific physical key is held. Define actions instead:

```odin
Action :: enum {
    Move_Left,
    Move_Right,
    Jump,
    Confirm,
    Cancel,
}
```

Bindings map keys, mouse buttons, or controller controls to actions. This supports rebinding, multiple devices, accessibility, and platform differences.

## 34.6 Text input is not key input

Keyboard keys represent physical controls. Text input represents Unicode text after layout, modifiers, composition, and input-method processing. Editors and consoles must consume text events instead of converting key codes into characters manually.

## 34.7 Mouse coordinates and scaling

Distinguish among:

- window logical coordinates;
- framebuffer pixels;
- normalized viewport coordinates;
- world coordinates.

High-DPI displays can make window size differ from framebuffer size. Query both and make conversions explicit.

## 34.8 Focus and capture

When the application loses focus, clear held-button state or synthesize releases. Otherwise controls can remain stuck. Relative mouse mode and pointer capture should be explicit modes owned by the application.

## 34.9 Resize handling

A resize event can invalidate swapchain images, render targets, projection parameters, and UI layout. Record the new extent and perform expensive recreation at a controlled synchronization point rather than directly inside a native callback.

## 34.10 Frame loop

A minimal loop has clear phases:

```text
begin input frame
poll and translate events
update simulation
prepare render data
submit rendering
present
```

Do not allow random systems to poll the operating system independently. One event pump creates deterministic ordering.

## 34.11 Headless operation

Keep simulation and asset processing independent of window creation. Tests, servers, build tools, and offline pipelines should run without a display server.

## 34.12 Common mistakes

- leaking native handles throughout the engine;
- treating text input as key presses;
- confusing framebuffer and window dimensions;
- polling input from multiple subsystems;
- retaining held keys after focus loss;
- recreating graphics resources inside callbacks;
- coupling simulation startup to a visible window.

## 34.13 Chapter checklist

You should now be able to design a platform layer that owns window lifetime, translates events, maintains per-frame input state, supports action bindings, and isolates display-specific details.

## References

- [Odin vendor packages](https://pkg.odin-lang.org/vendor/)
- [SDL documentation](https://wiki.libsdl.org/)
- [GLFW documentation](https://www.glfw.org/docs/latest/)
- [Game Programming Patterns — Game Loop](https://gameprogrammingpatterns.com/game-loop.html)
