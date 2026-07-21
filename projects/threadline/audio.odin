package main

AUDIO_SAMPLE_RATE :: 48_000
AUDIO_CHANNELS :: 2
MAX_AUDIO_VOICES :: 128

Audio_Command_Kind :: enum {
    Play,
    Stop,
    Stop_All,
    Set_Master_Volume,
    Set_Voice_Volume,
    Set_Voice_Pan,
}

Audio_Command :: struct {
    kind: Audio_Command_Kind,
    sound: Audio_ID,
    voice: u32,
    volume: f32,
    pan: f32,
    loop: bool,
}

Audio_Clip :: struct {
    generation: u32,
    occupied: bool,
    samples: [4096]f32,
    sample_count: int,
    channels: u8,
    sample_rate: u32,
    asset: Asset_ID,
}

Audio_Voice :: struct {
    active: bool,
    clip: Audio_ID,
    cursor: f64,
    pitch: f32,
    volume: f32,
    pan: f32,
    loop: bool,
}

Audio_Stats :: struct {
    commands: u64,
    voices_started: u64,
    voices_stopped: u64,
    mixed_frames: u64,
    clipped_samples: u64,
    dropped_commands: u64,
}

Audio_System :: struct {
    clips: [64]Audio_Clip,
    voices: [MAX_AUDIO_VOICES]Audio_Voice,
    commands: [MAX_AUDIO_COMMANDS]Audio_Command,
    command_count: int,
    master_volume: f32,
    stats: Audio_Stats,
}

audio_clip_valid :: proc(audio: ^Audio_System, id: Audio_ID) -> bool {
    return id.index < u32(len(audio.clips)) && audio.clips[id.index].occupied && audio.clips[id.index].generation == id.generation
}

audio_create_clip :: proc(audio: ^Audio_System, samples: []f32, channels: int = 1, sample_rate: int = AUDIO_SAMPLE_RATE, asset: Asset_ID = {}) -> (Audio_ID, Result) {
    if len(samples) == 0 || len(samples) > len(audio.clips[0].samples) || channels <= 0 || channels > 2 || sample_rate <= 0 {
        return {}, result_error(.Invalid_Argument, "invalid audio clip")
    }
    for i in 0..<len(audio.clips) {
        clip := &audio.clips[i]
        if !clip.occupied {
            if clip.generation == 0 { clip.generation = 1 }
            clip.occupied = true
            clip.sample_count = len(samples)
            clip.channels = u8(channels)
            clip.sample_rate = u32(sample_rate)
            clip.asset = asset
            copy(clip.samples[:len(samples)], samples)
            return Audio_ID{u32(i), clip.generation}, result_ok()
        }
    }
    return {}, result_error(.Capacity_Exceeded, "audio clip capacity exceeded")
}

audio_destroy_clip :: proc(audio: ^Audio_System, id: Audio_ID) -> Result {
    if !audio_clip_valid(audio, id) { return result_error(.Stale_Handle, "invalid audio clip") }
    for &voice in audio.voices {
        if voice.active && voice.clip == id { voice.active = false }
    }
    clip := &audio.clips[id.index]
    clip.occupied = false
    clip.generation = next_generation(clip.generation)
    clip.sample_count = 0
    clip.asset = {}
    return result_ok()
}

audio_push_command :: proc(audio: ^Audio_System, command: Audio_Command) -> bool {
    if audio.command_count >= len(audio.commands) {
        audio.stats.dropped_commands += 1
        return false
    }
    audio.commands[audio.command_count] = command
    audio.command_count += 1
    return true
}

audio_play :: proc(audio: ^Audio_System, sound: Audio_ID, volume: f32 = 1, pan: f32 = 0, loop: bool = false) -> bool {
    return audio_push_command(audio, Audio_Command{kind = .Play, sound = sound, volume = volume, pan = pan, loop = loop})
}

audio_stop_voice :: proc(audio: ^Audio_System, voice: u32) -> bool {
    return audio_push_command(audio, Audio_Command{kind = .Stop, voice = voice})
}

audio_find_free_voice :: proc(audio: ^Audio_System) -> (u32, bool) {
    for i in 0..<len(audio.voices) {
        if !audio.voices[i].active { return u32(i), true }
    }
    return 0, false
}

audio_process_commands :: proc(audio: ^Audio_System) {
    for command in audio.commands[:audio.command_count] {
        audio.stats.commands += 1
        switch command.kind {
        case .Play:
            if !audio_clip_valid(audio, command.sound) { continue }
            voice_index, found := audio_find_free_voice(audio)
            if !found { continue }
            audio.voices[voice_index] = Audio_Voice{
                active = true,
                clip = command.sound,
                pitch = 1,
                volume = clamp(command.volume, 0.0, 4.0),
                pan = clamp(command.pan, -1.0, 1.0),
                loop = command.loop,
            }
            audio.stats.voices_started += 1
        case .Stop:
            if command.voice < u32(len(audio.voices)) && audio.voices[command.voice].active {
                audio.voices[command.voice].active = false
                audio.stats.voices_stopped += 1
            }
        case .Stop_All:
            for &voice in audio.voices { voice.active = false }
        case .Set_Master_Volume:
            audio.master_volume = clamp(command.volume, 0.0, 4.0)
        case .Set_Voice_Volume:
            if command.voice < u32(len(audio.voices)) { audio.voices[command.voice].volume = clamp(command.volume, 0.0, 4.0) }
        case .Set_Voice_Pan:
            if command.voice < u32(len(audio.voices)) { audio.voices[command.voice].pan = clamp(command.pan, -1.0, 1.0) }
        }
    }
    audio.command_count = 0
}

audio_mix :: proc(audio: ^Audio_System, output: []f32) {
    if audio.master_volume == 0 { audio.master_volume = 1 }
    for &sample in output { sample = 0 }
    frame_count := len(output)/AUDIO_CHANNELS
    for &voice in audio.voices {
        if !voice.active || !audio_clip_valid(audio, voice.clip) { continue }
        clip := &audio.clips[voice.clip.index]
        for frame in 0..<frame_count {
            sample_index := int(voice.cursor)*int(clip.channels)
            if sample_index >= clip.sample_count {
                if voice.loop { voice.cursor = 0; sample_index = 0 } else { voice.active = false; audio.stats.voices_stopped += 1; break }
            }
            mono := clip.samples[sample_index]
            left_gain := voice.volume*(1.0-max(0.0, voice.pan))*audio.master_volume
            right_gain := voice.volume*(1.0+min(0.0, voice.pan))*audio.master_volume
            output[frame*2] += mono*left_gain
            output[frame*2+1] += mono*right_gain
            voice.cursor += f64(voice.pitch)*f64(clip.sample_rate)/AUDIO_SAMPLE_RATE
        }
    }
    for &sample in output {
        if sample < -1 || sample > 1 { audio.stats.clipped_samples += 1 }
        sample = clamp(sample, -1.0, 1.0)
    }
    audio.stats.mixed_frames += u64(frame_count)
}

audio_self_check :: proc() {
    audio := Audio_System{master_volume = 1}
    samples := [?]f32{0, 0.5, 1, 0.5, 0, -0.5, -1, -0.5}
    clip, result := audio_create_clip(&audio, samples[:])
    assert(result_is_ok(result))
    assert(audio_play(&audio, clip, 0.5))
    audio_process_commands(&audio)
    output: [32]f32
    audio_mix(&audio, output[:])
    assert(audio.stats.voices_started == 1)
    assert(audio.stats.mixed_frames == 16)
    assert(result_is_ok(audio_destroy_clip(&audio, clip)))
}
