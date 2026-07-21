# Chapter 38 — Audio and Event Systems

[← Chapter 37: Cameras, Transforms, and Scenes](37-cameras-transforms-scenes.md) · [Exercises](../exercises/38-audio-event-systems.md) · [Chapter 39: Immediate-Mode Tools and Editor UI →](39-immediate-mode-tools-editor-ui.md)

Audio is a real-time subsystem with strict timing constraints. Event systems connect gameplay intent to audio behavior, but careless global messaging can hide dependencies and produce nondeterministic behavior.

## 38.1 Audio architecture

Separate:

- asset decoding and streaming;
- game-side audio commands;
- the mixer and audio callback;
- backend device management.

The audio callback must not block, allocate unpredictably, perform file I/O, or acquire contested locks.

## 38.2 Samples, channels, and frames

Digital audio is a sequence of samples. Interleaved stereo usually stores left and right samples for each frame. Important metadata includes sample rate, channel count, sample format, and frame count.

Do not confuse byte count, sample count, and frame count.

## 38.3 The mixer

A mixer accumulates active voices into an output buffer. Each voice tracks playback position, gain, pitch or resampling state, looping, and routing. Clamp or limit the final mix to prevent uncontrolled clipping.

Use floating-point internal mixing unless platform constraints require otherwise.

## 38.4 Voice handles

Represent playing sounds with generation-checked handles. A voice can end asynchronously, so stale handles must fail safely.

```odin
Voice_Handle :: struct {
    index: u32,
    generation: u32,
}
```

Commands such as stop, set gain, or set position validate the handle before mutating state.

## 38.5 Command queues

The game thread should enqueue compact commands for the audio thread:

```text
Play(asset, parameters)
Stop(voice)
Set_Gain(voice, value)
Set_Listener(transform)
```

A single-producer/single-consumer ring buffer is often enough. Define overflow behavior explicitly: drop, coalesce, or reserve capacity.

## 38.6 Spatial audio

Spatialization uses listener and emitter positions to calculate attenuation, panning, delay, and optional filtering. Keep world-unit assumptions explicit. Update spatial parameters at a controlled rate rather than sending large mutable objects to the callback.

## 38.7 Streaming

Large music or ambience files should stream through decoded chunks. Maintain a buffer queue and handle underruns visibly. Decoding belongs on a worker thread, not in the device callback.

## 38.8 Events as contracts

Events are useful when producers and consumers should remain decoupled. Define small, typed payloads:

```odin
Damage_Event :: struct {
    target: Entity,
    amount: f32,
}
```

Prefer explicit queues per domain over one universal untyped event bus.

## 38.9 Immediate and deferred events

Immediate dispatch executes consumers during publication and can cause reentrancy. Deferred dispatch records events and processes them at a known phase. Games generally benefit from deterministic deferred queues.

## 38.10 Event ownership

Payloads must remain valid until consumption. Store values or stable handles rather than borrowed slices into temporary memory. Reset queues only after every consumer has completed.

## 38.11 Audio events versus audio commands

A gameplay event such as `Explosion_Occurred` describes a fact. An audio command such as `Play(explosion_sound)` requests subsystem behavior. Keep the translation in an audio presentation system so gameplay does not depend on sound assets.

## 38.12 Common mistakes

- allocating in the audio callback;
- performing decoding on the mixer thread;
- using raw indexes as voice IDs;
- blocking on a mutex shared with gameplay;
- publishing borrowed temporary data;
- building a global event bus with invisible dependencies;
- dispatching recursively without reentrancy rules.

## 38.13 Chapter checklist

You should understand mixer structure, real-time callback constraints, voice handles, command queues, streaming, spatial parameters, and deterministic typed event dispatch.

## References

- [SDL audio documentation](https://wiki.libsdl.org/SDL3/CategoryAudio)
- [PortAudio documentation](https://www.portaudio.com/docs/)
- [Game Programming Patterns — Event Queue](https://gameprogrammingpatterns.com/event-queue.html)
