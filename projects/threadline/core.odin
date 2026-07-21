package main

import "core:fmt"

Engine_Version :: struct {
    major: u16,
    minor: u16,
    patch: u16,
}

ENGINE_VERSION :: Engine_Version{1, 0, 0}
MAX_ENTITIES :: 2048
MAX_ASSETS :: 512
MAX_RENDER_COMMANDS :: 8192
MAX_AUDIO_COMMANDS :: 1024
MAX_EVENTS :: 2048
MAX_HISTORY :: 512
MAX_PATH_BYTES :: 256
MAX_NAME_BYTES :: 64

Engine_Error :: enum {
    None,
    Invalid_Argument,
    Capacity_Exceeded,
    Not_Found,
    Stale_Handle,
    Invalid_State,
    Invalid_Format,
    Unsupported_Version,
    Checksum_Mismatch,
    Dependency_Failed,
    Platform_Failure,
    Backend_Failure,
}

Result :: struct {
    error: Engine_Error,
    message: string,
}

result_ok :: proc() -> Result {
    return Result{.None, ""}
}

result_error :: proc(error: Engine_Error, message: string) -> Result {
    return Result{error, message}
}

result_is_ok :: proc(result: Result) -> bool {
    return result.error == .None
}

Entity_ID :: struct {
    index: u32,
    generation: u32,
}

Asset_ID :: struct {
    index: u32,
    generation: u32,
}

Texture_ID :: struct {
    index: u32,
    generation: u32,
}

Mesh_ID :: struct {
    index: u32,
    generation: u32,
}

Material_ID :: struct {
    index: u32,
    generation: u32,
}

Audio_ID :: struct {
    index: u32,
    generation: u32,
}

Scene_ID :: struct {
    index: u32,
    generation: u32,
}

Command_ID :: struct {
    value: u64,
}

Asset_Key :: struct {
    value: u64,
}

Name :: struct {
    bytes: [MAX_NAME_BYTES]u8,
    count: u8,
}

Path :: struct {
    bytes: [MAX_PATH_BYTES]u8,
    count: u16,
}

Vec2 :: struct {
    x: f32,
    y: f32,
}

Vec3 :: struct {
    x: f32,
    y: f32,
    z: f32,
}

Vec4 :: struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
}

Colour :: struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
}

Rect :: struct {
    min: Vec2,
    max: Vec2,
}

Transform_2D :: struct {
    position: Vec2,
    rotation: f32,
    scale: Vec2,
}

AABB :: struct {
    min: Vec2,
    max: Vec2,
}

name_from_string :: proc(text: string) -> (Name, bool) {
    if len(text) > MAX_NAME_BYTES {
        return {}, false
    }
    result: Name
    result.count = u8(len(text))
    if len(text) > 0 {
        copy(result.bytes[:len(text)], transmute([]u8)text)
    }
    return result, true
}

name_string :: proc(name: ^Name) -> string {
    return string(name.bytes[:name.count])
}

name_equal :: proc(a, b: ^Name) -> bool {
    if a.count != b.count {
        return false
    }
    for i in 0..<int(a.count) {
        if a.bytes[i] != b.bytes[i] {
            return false
        }
    }
    return true
}

path_from_string :: proc(text: string) -> (Path, bool) {
    if len(text) > MAX_PATH_BYTES {
        return {}, false
    }
    result: Path
    result.count = u16(len(text))
    if len(text) > 0 {
        copy(result.bytes[:len(text)], transmute([]u8)text)
    }
    return result, true
}

path_string :: proc(path: ^Path) -> string {
    return string(path.bytes[:path.count])
}

hash_bytes :: proc(bytes: []u8) -> u64 {
    value: u64 = 1469598103934665603
    for byte in bytes {
        value ^= u64(byte)
        value *= 1099511628211
    }
    return value
}

hash_string :: proc(text: string) -> u64 {
    return hash_bytes(transmute([]u8)text)
}

asset_key_from_path :: proc(path: ^Path) -> Asset_Key {
    return Asset_Key{hash_bytes(path.bytes[:path.count])}
}

vec2_add :: proc(a, b: Vec2) -> Vec2 {
    return Vec2{a.x+b.x, a.y+b.y}
}

vec2_sub :: proc(a, b: Vec2) -> Vec2 {
    return Vec2{a.x-b.x, a.y-b.y}
}

vec2_scale :: proc(v: Vec2, scalar: f32) -> Vec2 {
    return Vec2{v.x*scalar, v.y*scalar}
}

vec2_dot :: proc(a, b: Vec2) -> f32 {
    return a.x*b.x + a.y*b.y
}

vec2_length_squared :: proc(v: Vec2) -> f32 {
    return vec2_dot(v, v)
}

vec2_min :: proc(a, b: Vec2) -> Vec2 {
    return Vec2{min(a.x, b.x), min(a.y, b.y)}
}

vec2_max :: proc(a, b: Vec2) -> Vec2 {
    return Vec2{max(a.x, b.x), max(a.y, b.y)}
}

rect_width :: proc(rect: Rect) -> f32 {
    return rect.max.x - rect.min.x
}

rect_height :: proc(rect: Rect) -> f32 {
    return rect.max.y - rect.min.y
}

rect_contains :: proc(rect: Rect, point: Vec2) -> bool {
    return point.x >= rect.min.x && point.x <= rect.max.x &&
           point.y >= rect.min.y && point.y <= rect.max.y
}

aabb_overlaps :: proc(a, b: AABB) -> bool {
    return a.min.x <= b.max.x && a.max.x >= b.min.x &&
           a.min.y <= b.max.y && a.max.y >= b.min.y
}

colour_clamp :: proc(c: Colour) -> Colour {
    return Colour{
        clamp(c.r, 0.0, 1.0),
        clamp(c.g, 0.0, 1.0),
        clamp(c.b, 0.0, 1.0),
        clamp(c.a, 0.0, 1.0),
    }
}

colour_to_rgba8 :: proc(c: Colour) -> u32 {
    bounded := colour_clamp(c)
    r := u32(bounded.r*255.0+0.5)
    g := u32(bounded.g*255.0+0.5)
    b := u32(bounded.b*255.0+0.5)
    a := u32(bounded.a*255.0+0.5)
    return r | g<<8 | b<<16 | a<<24
}

next_generation :: proc(current: u32) -> u32 {
    result := current + 1
    if result == 0 {
        result = 1
    }
    return result
}

format_version :: proc(version: Engine_Version) -> string {
    return fmt.tprintf("%d.%d.%d", version.major, version.minor, version.patch)
}

fixed_step_count :: proc(accumulator: ^f64, frame_dt, fixed_dt: f64, max_steps: int) -> int {
    if frame_dt < 0 || fixed_dt <= 0 || max_steps <= 0 {
        return 0
    }
    accumulator^ += frame_dt
    steps := 0
    for accumulator^ >= fixed_dt && steps < max_steps {
        accumulator^ -= fixed_dt
        steps += 1
    }
    if steps == max_steps && accumulator^ >= fixed_dt {
        accumulator^ = 0
    }
    return steps
}

core_self_check :: proc() {
    name, ok := name_from_string("Threadline")
    assert(ok)
    assert(name_string(&name) == "Threadline")

    path, ok := path_from_string("assets/player.sprite")
    assert(ok)
    assert(asset_key_from_path(&path).value != 0)

    accumulator: f64
    steps := fixed_step_count(&accumulator, 1.0/30.0, 1.0/60.0, 8)
    assert(steps == 2)

    assert(aabb_overlaps(
        AABB{{0, 0}, {2, 2}},
        AABB{{1, 1}, {3, 3}},
    ))
}
