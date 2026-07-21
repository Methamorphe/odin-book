# Chapter 34 Exercises — Window Creation and Input

[← Chapter](../book/34-window-creation-input.md) · [Solutions](../solutions/34-window-creation-input.md)

1. Define a backend-independent `Window_Desc` and explain every field.
2. Design an `Event` union covering quit, resize, keyboard, mouse, and text input.
3. Implement `begin_input_frame` so transient button states are reset while held state remains.
4. Convert key-down and key-up events into `Button_State` transitions.
5. Design an action-binding table supporting two physical controls per action.
6. Explain why text input cannot be reconstructed reliably from key codes.
7. Write explicit conversions between logical window coordinates and framebuffer pixels.
8. Define the behavior required when focus is lost.

## Challenge

Design a small platform package API with initialization, window creation, event polling, framebuffer-size queries, relative mouse mode, and shutdown. Keep every native type private.