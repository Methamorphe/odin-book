package main

import "core:time"

Platform_Event_Kind :: enum {
    None,
    Quit,
    Focus_Gained,
    Focus_Lost,
    Key_Down,
    Key_Up,
    Mouse_Move,
    Mouse_Button_Down,
    Mouse_Button_Up,
    Mouse_Wheel,
    Text_Input,
    Window_Resized,
    File_Changed,
}

Key_Code :: enum u16 {
    Unknown,
    A, B, C, D, E, F, G, H, I, J, K, L, M,
    N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    Num_0, Num_1, Num_2, Num_3, Num_4,
    Num_5, Num_6, Num_7, Num_8, Num_9,
    Escape, Enter, Space, Tab, Backspace,
    Left, Right, Up, Down,
    Shift, Control, Alt,
    F1, F2, F3, F4, F5, F6,
    F7, F8, F9, F10, F11, F12,
}

Mouse_Button :: enum u8 {
    Left,
    Right,
    Middle,
    Extra_1,
    Extra_2,
}

Platform_Event :: struct {
    kind: Platform_Event_Kind,
    sequence: u64,
    timestamp_ns: u64,
    key: Key_Code,
    mouse_button: Mouse_Button,
    mouse_position: Vec2,
    mouse_delta: Vec2,
    wheel_delta: f32,
    width: i32,
    height: i32,
    text: [8]u8,
    text_count: u8,
    path: Path,
}

Platform_Config :: struct {
    title: Name,
    width: i32,
    height: i32,
    headless: bool,
    deterministic_time: bool,
    fixed_time_step_ns: u64,
}

Platform_Stats :: struct {
    frames: u64,
    events_pushed: u64,
    events_dropped: u64,
    sleeps: u64,
    sleep_ns: u64,
}

Platform :: struct {
    config: Platform_Config,
    events: Event_Queue,
    running: bool,
    focused: bool,
    frame_index: u64,
    event_sequence: u64,
    deterministic_now_ns: u64,
    startup_ns: u64,
    executable_dir: Path,
    user_data_dir: Path,
    stats: Platform_Stats,
}

platform_monotonic_ns :: proc() -> u64 {
    return u64(time.duration_nanoseconds(time.since(time.Time{})))
}

platform_init :: proc(platform: ^Platform, config: Platform_Config) -> Result {
    if config.width <= 0 || config.height <= 0 {
        return result_error(.Invalid_Argument, "invalid platform dimensions")
    }
    if config.deterministic_time && config.fixed_time_step_ns == 0 {
        return result_error(.Invalid_Argument, "deterministic time requires a fixed step")
    }

    executable_dir, ok := path_from_string(".")
    if !ok {
        return result_error(.Platform_Failure, "failed to initialize executable directory")
    }
    user_data_dir, ok := path_from_string("./threadline-user")
    if !ok {
        return result_error(.Platform_Failure, "failed to initialize user data directory")
    }

    platform^ = Platform{
        config = config,
        running = true,
        focused = true,
        executable_dir = executable_dir,
        user_data_dir = user_data_dir,
    }
    platform.startup_ns = platform_monotonic_ns()
    return result_ok()
}

platform_shutdown :: proc(platform: ^Platform) {
    platform.running = false
    event_queue_clear(&platform.events)
}

platform_now_ns :: proc(platform: ^Platform) -> u64 {
    if platform.config.deterministic_time {
        return platform.deterministic_now_ns
    }
    return platform_monotonic_ns()-platform.startup_ns
}

platform_begin_frame :: proc(platform: ^Platform) {
    platform.frame_index += 1
    platform.stats.frames += 1
    if platform.config.deterministic_time {
        platform.deterministic_now_ns += platform.config.fixed_time_step_ns
    }
}

platform_make_event :: proc(platform: ^Platform, kind: Platform_Event_Kind) -> Platform_Event {
    event := Platform_Event{
        kind = kind,
        sequence = platform.event_sequence,
        timestamp_ns = platform_now_ns(platform),
    }
    platform.event_sequence += 1
    return event
}

platform_push_event :: proc(platform: ^Platform, event: Platform_Event) -> bool {
    pushed := event_queue_push(&platform.events, event)
    if pushed {
        platform.stats.events_pushed += 1
    } else {
        platform.stats.events_dropped += 1
    }
    return pushed
}

platform_push_key :: proc(platform: ^Platform, key: Key_Code, down: bool) -> bool {
    event := platform_make_event(platform, down ? .Key_Down : .Key_Up)
    event.key = key
    return platform_push_event(platform, event)
}

platform_push_mouse_move :: proc(platform: ^Platform, position, delta: Vec2) -> bool {
    event := platform_make_event(platform, .Mouse_Move)
    event.mouse_position = position
    event.mouse_delta = delta
    return platform_push_event(platform, event)
}

platform_push_resize :: proc(platform: ^Platform, width, height: i32) -> bool {
    if width <= 0 || height <= 0 {
        return false
    }
    event := platform_make_event(platform, .Window_Resized)
    event.width = width
    event.height = height
    return platform_push_event(platform, event)
}

platform_push_file_changed :: proc(platform: ^Platform, changed_path: string) -> bool {
    path, ok := path_from_string(changed_path)
    if !ok {
        return false
    }
    event := platform_make_event(platform, .File_Changed)
    event.path = path
    return platform_push_event(platform, event)
}

platform_poll_event :: proc(platform: ^Platform) -> (Platform_Event, bool) {
    event, ok := event_queue_pop(&platform.events)
    if !ok {
        return {}, false
    }
    switch event.kind {
    case .Quit:
        platform.running = false
    case .Focus_Gained:
        platform.focused = true
    case .Focus_Lost:
        platform.focused = false
    case .Window_Resized:
        platform.config.width = event.width
        platform.config.height = event.height
    }
    return event, true
}

platform_request_quit :: proc(platform: ^Platform) {
    event := platform_make_event(platform, .Quit)
    _ = platform_push_event(platform, event)
}

platform_is_running :: proc(platform: ^Platform) -> bool {
    return platform.running
}

platform_aspect_ratio :: proc(platform: ^Platform) -> f32 {
    return f32(platform.config.width)/f32(platform.config.height)
}

platform_resolve_executable_path :: proc(platform: ^Platform, relative: string) -> (Path, Result) {
    base := path_string(&platform.executable_dir)
    combined := base+"/"+relative
    path, ok := path_from_string(combined)
    if !ok {
        return {}, result_error(.Invalid_Argument, "resolved path is too long")
    }
    return path, result_ok()
}

platform_resolve_user_path :: proc(platform: ^Platform, relative: string) -> (Path, Result) {
    base := path_string(&platform.user_data_dir)
    combined := base+"/"+relative
    path, ok := path_from_string(combined)
    if !ok {
        return {}, result_error(.Invalid_Argument, "resolved user path is too long")
    }
    return path, result_ok()
}

platform_self_check :: proc() {
    title, ok := name_from_string("Threadline Test")
    assert(ok)
    platform: Platform
    result := platform_init(&platform, Platform_Config{
        title = title,
        width = 1280,
        height = 720,
        headless = true,
        deterministic_time = true,
        fixed_time_step_ns = 16_666_667,
    })
    assert(result_is_ok(result))
    platform_begin_frame(&platform)
    assert(platform_now_ns(&platform) == 16_666_667)
    assert(platform_push_key(&platform, .Space, true))
    event, found := platform_poll_event(&platform)
    assert(found && event.kind == .Key_Down && event.key == .Space)
    assert(platform_aspect_ratio(&platform) > 1.7)
    platform_shutdown(&platform)
}
