package main

MAX_KEYS :: 128
MAX_ACTIONS :: 64
MAX_BINDINGS :: 128
MAX_RECORDED_INPUTS :: 8192

Button_State :: struct {
    down: bool,
    pressed: bool,
    released: bool,
    transitions: u8,
}

Raw_Input :: struct {
    keys: [MAX_KEYS]Button_State,
    mouse_buttons: [5]Button_State,
    mouse_position: Vec2,
    mouse_delta: Vec2,
    wheel_delta: f32,
    focused: bool,
    text: [64]u8,
    text_count: int,
}

Action :: enum u16 {
    None,
    Move_Left,
    Move_Right,
    Move_Up,
    Move_Down,
    Jump,
    Dash,
    Interact,
    Pause,
    Toggle_Editor,
    Save,
    Load,
    Undo,
    Redo,
    Count,
}

Binding_Kind :: enum {
    Key,
    Mouse_Button,
}

Action_Binding :: struct {
    action: Action,
    kind: Binding_Kind,
    key: Key_Code,
    mouse_button: Mouse_Button,
    scale: f32,
}

Action_State :: struct {
    value: f32,
    down: bool,
    pressed: bool,
    released: bool,
}

Action_Map :: struct {
    bindings: [MAX_BINDINGS]Action_Binding,
    binding_count: int,
    states: [MAX_ACTIONS]Action_State,
}

Recorded_Input :: struct {
    frame: u64,
    action: Action,
    value: f32,
    down: bool,
    pressed: bool,
    released: bool,
}

Input_Recording :: struct {
    records: [MAX_RECORDED_INPUTS]Recorded_Input,
    count: int,
    replay_index: int,
    recording: bool,
    replaying: bool,
    overflowed: bool,
}

button_begin_frame :: proc(button: ^Button_State) {
    button.pressed = false
    button.released = false
    button.transitions = 0
}

button_set :: proc(button: ^Button_State, down: bool) {
    if button.down == down {
        return
    }
    button.down = down
    button.transitions += 1
    if down {
        button.pressed = true
    } else {
        button.released = true
    }
}

raw_input_begin_frame :: proc(input: ^Raw_Input) {
    for &key in input.keys {
        button_begin_frame(&key)
    }
    for &button in input.mouse_buttons {
        button_begin_frame(&button)
    }
    input.mouse_delta = {}
    input.wheel_delta = 0
    input.text_count = 0
}

raw_input_release_all :: proc(input: ^Raw_Input) {
    for &key in input.keys {
        if key.down {
            button_set(&key, false)
        }
    }
    for &button in input.mouse_buttons {
        if button.down {
            button_set(&button, false)
        }
    }
}

raw_input_apply_event :: proc(input: ^Raw_Input, event: Platform_Event) {
    switch event.kind {
    case .Focus_Gained:
        input.focused = true
    case .Focus_Lost:
        input.focused = false
        raw_input_release_all(input)
    case .Key_Down:
        index := int(event.key)
        if index >= 0 && index < len(input.keys) {
            button_set(&input.keys[index], true)
        }
    case .Key_Up:
        index := int(event.key)
        if index >= 0 && index < len(input.keys) {
            button_set(&input.keys[index], false)
        }
    case .Mouse_Move:
        input.mouse_position = event.mouse_position
        input.mouse_delta = vec2_add(input.mouse_delta, event.mouse_delta)
    case .Mouse_Button_Down:
        index := int(event.mouse_button)
        if index >= 0 && index < len(input.mouse_buttons) {
            button_set(&input.mouse_buttons[index], true)
        }
    case .Mouse_Button_Up:
        index := int(event.mouse_button)
        if index >= 0 && index < len(input.mouse_buttons) {
            button_set(&input.mouse_buttons[index], false)
        }
    case .Mouse_Wheel:
        input.wheel_delta += event.wheel_delta
    case .Text_Input:
        available := len(input.text)-input.text_count
        count := min(int(event.text_count), available)
        if count > 0 {
            copy(input.text[input.text_count:input.text_count+count], event.text[:count])
            input.text_count += count
        }
    }
}

action_map_bind_key :: proc(map: ^Action_Map, action: Action, key: Key_Code, scale: f32 = 1) -> Result {
    if action == .None || int(action) >= MAX_ACTIONS {
        return result_error(.Invalid_Argument, "invalid action")
    }
    if map.binding_count >= len(map.bindings) {
        return result_error(.Capacity_Exceeded, "input binding capacity exceeded")
    }
    map.bindings[map.binding_count] = Action_Binding{
        action = action,
        kind = .Key,
        key = key,
        scale = scale,
    }
    map.binding_count += 1
    return result_ok()
}

action_map_bind_mouse :: proc(map: ^Action_Map, action: Action, button: Mouse_Button, scale: f32 = 1) -> Result {
    if action == .None || int(action) >= MAX_ACTIONS {
        return result_error(.Invalid_Argument, "invalid action")
    }
    if map.binding_count >= len(map.bindings) {
        return result_error(.Capacity_Exceeded, "input binding capacity exceeded")
    }
    map.bindings[map.binding_count] = Action_Binding{
        action = action,
        kind = .Mouse_Button,
        mouse_button = button,
        scale = scale,
    }
    map.binding_count += 1
    return result_ok()
}

action_map_begin_frame :: proc(map: ^Action_Map) {
    for &state in map.states {
        state.value = 0
        state.pressed = false
        state.released = false
    }
}

action_map_update :: proc(map: ^Action_Map, input: ^Raw_Input) {
    action_map_begin_frame(map)
    for binding in map.bindings[:map.binding_count] {
        state := &map.states[int(binding.action)]
        source: Button_State
        switch binding.kind {
        case .Key:
            index := int(binding.key)
            if index >= 0 && index < len(input.keys) {
                source = input.keys[index]
            }
        case .Mouse_Button:
            index := int(binding.mouse_button)
            if index >= 0 && index < len(input.mouse_buttons) {
                source = input.mouse_buttons[index]
            }
        }
        if source.down {
            state.value += binding.scale
            state.down = true
        }
        state.pressed = state.pressed || source.pressed
        state.released = state.released || source.released
    }
    for &state in map.states {
        if state.value == 0 {
            state.down = false
        }
        state.value = clamp(state.value, -1.0, 1.0)
    }
}

action_state :: proc(map: ^Action_Map, action: Action) -> Action_State {
    index := int(action)
    if index < 0 || index >= len(map.states) {
        return {}
    }
    return map.states[index]
}

input_record_begin :: proc(recording: ^Input_Recording) {
    recording.count = 0
    recording.replay_index = 0
    recording.recording = true
    recording.replaying = false
    recording.overflowed = false
}

input_record_frame :: proc(recording: ^Input_Recording, frame: u64, map: ^Action_Map) {
    if !recording.recording {
        return
    }
    for action_index in 1..<int(Action.Count) {
        state := map.states[action_index]
        if state.value == 0 && !state.pressed && !state.released {
            continue
        }
        if recording.count >= len(recording.records) {
            recording.overflowed = true
            recording.recording = false
            return
        }
        recording.records[recording.count] = Recorded_Input{
            frame = frame,
            action = Action(action_index),
            value = state.value,
            down = state.down,
            pressed = state.pressed,
            released = state.released,
        }
        recording.count += 1
    }
}

input_replay_begin :: proc(recording: ^Input_Recording) {
    recording.replay_index = 0
    recording.recording = false
    recording.replaying = true
}

input_replay_frame :: proc(recording: ^Input_Recording, frame: u64, map: ^Action_Map) {
    action_map_begin_frame(map)
    if !recording.replaying {
        return
    }
    for recording.replay_index < recording.count {
        record := recording.records[recording.replay_index]
        if record.frame > frame {
            break
        }
        recording.replay_index += 1
        if record.frame < frame {
            continue
        }
        state := &map.states[int(record.action)]
        state.value = record.value
        state.down = record.down
        state.pressed = record.pressed
        state.released = record.released
    }
    if recording.replay_index >= recording.count {
        recording.replaying = false
    }
}

input_default_bindings :: proc(map: ^Action_Map) -> Result {
    bindings := [?]Action_Binding{
        {.Move_Left, .Key, .A, {}, -1},
        {.Move_Left, .Key, .Left, {}, -1},
        {.Move_Right, .Key, .D, {}, 1},
        {.Move_Right, .Key, .Right, {}, 1},
        {.Move_Up, .Key, .W, {}, 1},
        {.Move_Up, .Key, .Up, {}, 1},
        {.Move_Down, .Key, .S, {}, -1},
        {.Move_Down, .Key, .Down, {}, -1},
        {.Jump, .Key, .Space, {}, 1},
        {.Pause, .Key, .Escape, {}, 1},
        {.Toggle_Editor, .Key, .F1, {}, 1},
        {.Save, .Key, .F5, {}, 1},
        {.Load, .Key, .F9, {}, 1},
    }
    for binding in bindings {
        if map.binding_count >= len(map.bindings) {
            return result_error(.Capacity_Exceeded, "default bindings exceed capacity")
        }
        map.bindings[map.binding_count] = binding
        map.binding_count += 1
    }
    return result_ok()
}

input_self_check :: proc() {
    input: Raw_Input
    input.focused = true
    map: Action_Map
    assert(result_is_ok(input_default_bindings(&map)))

    raw_input_begin_frame(&input)
    event := Platform_Event{kind = .Key_Down, key = .D}
    raw_input_apply_event(&input, event)
    action_map_update(&map, &input)
    right := action_state(&map, .Move_Right)
    assert(right.down && right.pressed && right.value == 1)

    recording: Input_Recording
    input_record_begin(&recording)
    input_record_frame(&recording, 1, &map)
    assert(recording.count > 0)
    input_replay_begin(&recording)
    replay_map: Action_Map
    input_replay_frame(&recording, 1, &replay_map)
    assert(action_state(&replay_map, .Move_Right).down)
}
