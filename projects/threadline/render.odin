package main

FRAMEBUFFER_WIDTH :: 320
FRAMEBUFFER_HEIGHT :: 180
MAX_TEXTURES :: 256
MAX_MESHES :: 256
MAX_MATERIALS :: 256

Render_Command_Kind :: enum {
    None,
    Clear,
    Rectangle,
    Line,
    Circle,
    Sprite,
    Mesh,
    Text,
    Scissor_Begin,
    Scissor_End,
}

Blend_Mode :: enum {
    Opaque,
    Alpha,
    Additive,
    Multiply,
}

Texture_Record :: struct {
    generation: u32,
    occupied: bool,
    width: u16,
    height: u16,
    pixel_offset: u32,
    pixel_count: u32,
    asset: Asset_ID,
}

Mesh_Vertex :: struct {
    position: Vec2,
    uv: Vec2,
    colour: Colour,
}

Mesh_Record :: struct {
    generation: u32,
    occupied: bool,
    vertex_offset: u32,
    vertex_count: u32,
    index_offset: u32,
    index_count: u32,
    asset: Asset_ID,
}

Material_Record :: struct {
    generation: u32,
    occupied: bool,
    texture: Texture_ID,
    tint: Colour,
    blend: Blend_Mode,
    sort_key: u32,
    asset: Asset_ID,
}

Render_Command :: struct {
    kind: Render_Command_Kind,
    layer: i16,
    sort_key: u32,
    transform: Transform_2D,
    colour: Colour,
    rect: Rect,
    line_a: Vec2,
    line_b: Vec2,
    thickness: f32,
    radius: f32,
    texture: Texture_ID,
    mesh: Mesh_ID,
    material: Material_ID,
    source_rect: Rect,
    text_id: u32,
}

Render_Command_Buffer :: struct {
    commands: [MAX_RENDER_COMMANDS]Render_Command,
    count: int,
    dropped: u64,
    frame_index: u64,
}

Renderer_Stats :: struct {
    frame_index: u64,
    commands_submitted: u64,
    commands_executed: u64,
    commands_dropped: u64,
    pixels_written: u64,
    resource_failures: u64,
    draw_calls: u64,
    clears: u64,
}

Renderer :: struct {
    textures: [MAX_TEXTURES]Texture_Record,
    meshes: [MAX_MESHES]Mesh_Record,
    materials: [MAX_MATERIALS]Material_Record,
    texture_pixels: [1024*1024]u32,
    texture_pixel_count: int,
    vertices: [64*1024]Mesh_Vertex,
    vertex_count: int,
    indices: [128*1024]u32,
    index_count: int,
    commands: Render_Command_Buffer,
    framebuffer: [FRAMEBUFFER_WIDTH*FRAMEBUFFER_HEIGHT]u32,
    depth: [FRAMEBUFFER_WIDTH*FRAMEBUFFER_HEIGHT]f32,
    scissor_stack: [16]Rect,
    scissor_count: int,
    stats: Renderer_Stats,
}

render_buffer_begin :: proc(buffer: ^Render_Command_Buffer, frame_index: u64) {
    buffer.count = 0
    buffer.frame_index = frame_index
}

render_push :: proc(buffer: ^Render_Command_Buffer, command: Render_Command) -> bool {
    if buffer.count >= len(buffer.commands) {
        buffer.dropped += 1
        return false
    }
    buffer.commands[buffer.count] = command
    buffer.count += 1
    return true
}

render_push_clear :: proc(buffer: ^Render_Command_Buffer, colour: Colour) -> bool {
    return render_push(buffer, Render_Command{kind = .Clear, colour = colour, layer = -32768})
}

render_push_rect :: proc(buffer: ^Render_Command_Buffer, rect: Rect, colour: Colour, layer: i16 = 0) -> bool {
    return render_push(buffer, Render_Command{kind = .Rectangle, rect = rect, colour = colour, layer = layer})
}

render_push_line :: proc(buffer: ^Render_Command_Buffer, a, b: Vec2, colour: Colour, thickness: f32 = 1, layer: i16 = 0) -> bool {
    return render_push(buffer, Render_Command{
        kind = .Line,
        line_a = a,
        line_b = b,
        colour = colour,
        thickness = thickness,
        layer = layer,
    })
}

render_push_circle :: proc(buffer: ^Render_Command_Buffer, center: Vec2, radius: f32, colour: Colour, layer: i16 = 0) -> bool {
    return render_push(buffer, Render_Command{
        kind = .Circle,
        transform = Transform_2D{position = center, scale = {1, 1}},
        radius = radius,
        colour = colour,
        layer = layer,
    })
}

render_push_sprite :: proc(buffer: ^Render_Command_Buffer, transform: Transform_2D, texture: Texture_ID, material: Material_ID, layer: i16 = 0) -> bool {
    return render_push(buffer, Render_Command{
        kind = .Sprite,
        transform = transform,
        texture = texture,
        material = material,
        layer = layer,
    })
}

renderer_texture_valid :: proc(renderer: ^Renderer, id: Texture_ID) -> bool {
    return id.index < MAX_TEXTURES && renderer.textures[id.index].occupied && renderer.textures[id.index].generation == id.generation
}

renderer_mesh_valid :: proc(renderer: ^Renderer, id: Mesh_ID) -> bool {
    return id.index < MAX_MESHES && renderer.meshes[id.index].occupied && renderer.meshes[id.index].generation == id.generation
}

renderer_material_valid :: proc(renderer: ^Renderer, id: Material_ID) -> bool {
    return id.index < MAX_MATERIALS && renderer.materials[id.index].occupied && renderer.materials[id.index].generation == id.generation
}

renderer_create_texture :: proc(renderer: ^Renderer, width, height: int, pixels: []u32, asset: Asset_ID = {}) -> (Texture_ID, Result) {
    if width <= 0 || height <= 0 || width*height != len(pixels) || width > max(u16) || height > max(u16) {
        return {}, result_error(.Invalid_Argument, "invalid texture dimensions")
    }
    if renderer.texture_pixel_count+len(pixels) > len(renderer.texture_pixels) {
        return {}, result_error(.Capacity_Exceeded, "texture pixel storage exhausted")
    }
    for i in 0..<len(renderer.textures) {
        record := &renderer.textures[i]
        if !record.occupied {
            if record.generation == 0 { record.generation = 1 }
            offset := renderer.texture_pixel_count
            copy(renderer.texture_pixels[offset:offset+len(pixels)], pixels)
            renderer.texture_pixel_count += len(pixels)
            record.occupied = true
            record.width = u16(width)
            record.height = u16(height)
            record.pixel_offset = u32(offset)
            record.pixel_count = u32(len(pixels))
            record.asset = asset
            return Texture_ID{u32(i), record.generation}, result_ok()
        }
    }
    return {}, result_error(.Capacity_Exceeded, "texture handle storage exhausted")
}

renderer_destroy_texture :: proc(renderer: ^Renderer, id: Texture_ID) -> Result {
    if !renderer_texture_valid(renderer, id) {
        return result_error(.Stale_Handle, "invalid texture handle")
    }
    record := &renderer.textures[id.index]
    record.occupied = false
    record.generation = next_generation(record.generation)
    record.asset = {}
    return result_ok()
}

renderer_create_material :: proc(renderer: ^Renderer, texture: Texture_ID, tint: Colour, blend: Blend_Mode, sort_key: u32 = 0, asset: Asset_ID = {}) -> (Material_ID, Result) {
    if texture != Texture_ID{} && !renderer_texture_valid(renderer, texture) {
        return {}, result_error(.Stale_Handle, "invalid material texture")
    }
    for i in 0..<len(renderer.materials) {
        record := &renderer.materials[i]
        if !record.occupied {
            if record.generation == 0 { record.generation = 1 }
            record.occupied = true
            record.texture = texture
            record.tint = colour_clamp(tint)
            record.blend = blend
            record.sort_key = sort_key
            record.asset = asset
            return Material_ID{u32(i), record.generation}, result_ok()
        }
    }
    return {}, result_error(.Capacity_Exceeded, "material handle storage exhausted")
}

renderer_destroy_material :: proc(renderer: ^Renderer, id: Material_ID) -> Result {
    if !renderer_material_valid(renderer, id) {
        return result_error(.Stale_Handle, "invalid material handle")
    }
    record := &renderer.materials[id.index]
    record.occupied = false
    record.generation = next_generation(record.generation)
    record.texture = {}
    record.asset = {}
    return result_ok()
}

renderer_create_mesh :: proc(renderer: ^Renderer, vertices: []Mesh_Vertex, indices: []u32, asset: Asset_ID = {}) -> (Mesh_ID, Result) {
    if len(vertices) == 0 || len(indices) == 0 {
        return {}, result_error(.Invalid_Argument, "mesh requires vertices and indices")
    }
    for index in indices {
        if index >= u32(len(vertices)) {
            return {}, result_error(.Invalid_Argument, "mesh index out of range")
        }
    }
    if renderer.vertex_count+len(vertices) > len(renderer.vertices) || renderer.index_count+len(indices) > len(renderer.indices) {
        return {}, result_error(.Capacity_Exceeded, "mesh storage exhausted")
    }
    for i in 0..<len(renderer.meshes) {
        record := &renderer.meshes[i]
        if !record.occupied {
            if record.generation == 0 { record.generation = 1 }
            vertex_offset := renderer.vertex_count
            index_offset := renderer.index_count
            copy(renderer.vertices[vertex_offset:vertex_offset+len(vertices)], vertices)
            copy(renderer.indices[index_offset:index_offset+len(indices)], indices)
            renderer.vertex_count += len(vertices)
            renderer.index_count += len(indices)
            record.occupied = true
            record.vertex_offset = u32(vertex_offset)
            record.vertex_count = u32(len(vertices))
            record.index_offset = u32(index_offset)
            record.index_count = u32(len(indices))
            record.asset = asset
            return Mesh_ID{u32(i), record.generation}, result_ok()
        }
    }
    return {}, result_error(.Capacity_Exceeded, "mesh handle storage exhausted")
}

renderer_begin_frame :: proc(renderer: ^Renderer, frame_index: u64) {
    render_buffer_begin(&renderer.commands, frame_index)
    renderer.stats.frame_index = frame_index
    renderer.stats.commands_submitted = 0
    renderer.stats.commands_executed = 0
    renderer.stats.commands_dropped = renderer.commands.dropped
    renderer.stats.pixels_written = 0
    renderer.stats.draw_calls = 0
    renderer.stats.clears = 0
    renderer.scissor_count = 0
}

renderer_sort_commands :: proc(buffer: ^Render_Command_Buffer) {
    for i in 1..<buffer.count {
        value := buffer.commands[i]
        j := i
        for j > 0 {
            previous := buffer.commands[j-1]
            previous_key := (u64(u16(previous.layer+32768))<<32)|u64(previous.sort_key)
            value_key := (u64(u16(value.layer+32768))<<32)|u64(value.sort_key)
            if previous_key <= value_key { break }
            buffer.commands[j] = previous
            j -= 1
        }
        buffer.commands[j] = value
    }
}

renderer_clear :: proc(renderer: ^Renderer, colour: Colour) {
    packed := colour_to_rgba8(colour)
    for &pixel in renderer.framebuffer {
        pixel = packed
    }
    for &depth in renderer.depth {
        depth = 1.0
    }
    renderer.stats.pixels_written += len(renderer.framebuffer)
    renderer.stats.clears += 1
}

renderer_scissor_rect :: proc(renderer: ^Renderer) -> Rect {
    if renderer.scissor_count == 0 {
        return Rect{{0, 0}, {FRAMEBUFFER_WIDTH, FRAMEBUFFER_HEIGHT}}
    }
    return renderer.scissor_stack[renderer.scissor_count-1]
}

renderer_write_pixel :: proc(renderer: ^Renderer, x, y: int, colour: Colour) {
    if x < 0 || y < 0 || x >= FRAMEBUFFER_WIDTH || y >= FRAMEBUFFER_HEIGHT {
        return
    }
    scissor := renderer_scissor_rect(renderer)
    point := Vec2{f32(x), f32(y)}
    if !rect_contains(scissor, point) {
        return
    }
    renderer.framebuffer[y*FRAMEBUFFER_WIDTH+x] = colour_to_rgba8(colour)
    renderer.stats.pixels_written += 1
}

renderer_draw_rect :: proc(renderer: ^Renderer, rect: Rect, colour: Colour) {
    x0 := clamp(int(rect.min.x), 0, FRAMEBUFFER_WIDTH)
    y0 := clamp(int(rect.min.y), 0, FRAMEBUFFER_HEIGHT)
    x1 := clamp(int(rect.max.x+0.999), 0, FRAMEBUFFER_WIDTH)
    y1 := clamp(int(rect.max.y+0.999), 0, FRAMEBUFFER_HEIGHT)
    for y in y0..<y1 {
        for x in x0..<x1 {
            renderer_write_pixel(renderer, x, y, colour)
        }
    }
    renderer.stats.draw_calls += 1
}

renderer_draw_line :: proc(renderer: ^Renderer, a, b: Vec2, colour: Colour) {
    x0 := int(a.x)
    y0 := int(a.y)
    x1 := int(b.x)
    y1 := int(b.y)
    dx := abs(x1-x0)
    sx := x0 < x1 ? 1 : -1
    dy := -abs(y1-y0)
    sy := y0 < y1 ? 1 : -1
    error := dx+dy
    for {
        renderer_write_pixel(renderer, x0, y0, colour)
        if x0 == x1 && y0 == y1 { break }
        doubled := 2*error
        if doubled >= dy { error += dy; x0 += sx }
        if doubled <= dx { error += dx; y0 += sy }
    }
    renderer.stats.draw_calls += 1
}

renderer_draw_circle :: proc(renderer: ^Renderer, center: Vec2, radius: f32, colour: Colour) {
    r := max(0, int(radius))
    cx := int(center.x)
    cy := int(center.y)
    radius_squared := r*r
    for y in -r..=r {
        for x in -r..=r {
            if x*x+y*y <= radius_squared {
                renderer_write_pixel(renderer, cx+x, cy+y, colour)
            }
        }
    }
    renderer.stats.draw_calls += 1
}

renderer_draw_sprite :: proc(renderer: ^Renderer, command: Render_Command) {
    if !renderer_texture_valid(renderer, command.texture) {
        renderer.stats.resource_failures += 1
        return
    }
    texture := &renderer.textures[command.texture.index]
    material_colour := command.colour
    if renderer_material_valid(renderer, command.material) {
        material_colour = renderer.materials[command.material.index].tint
    }
    width := f32(texture.width)*command.transform.scale.x
    height := f32(texture.height)*command.transform.scale.y
    rect := Rect{
        min = command.transform.position,
        max = vec2_add(command.transform.position, Vec2{width, height}),
    }
    renderer_draw_rect(renderer, rect, material_colour)
}

renderer_execute :: proc(renderer: ^Renderer) {
    renderer.stats.commands_submitted = u64(renderer.commands.count)
    renderer_sort_commands(&renderer.commands)
    for command in renderer.commands.commands[:renderer.commands.count] {
        switch command.kind {
        case .Clear:
            renderer_clear(renderer, command.colour)
        case .Rectangle:
            renderer_draw_rect(renderer, command.rect, command.colour)
        case .Line:
            renderer_draw_line(renderer, command.line_a, command.line_b, command.colour)
        case .Circle:
            renderer_draw_circle(renderer, command.transform.position, command.radius, command.colour)
        case .Sprite:
            renderer_draw_sprite(renderer, command)
        case .Scissor_Begin:
            if renderer.scissor_count < len(renderer.scissor_stack) {
                renderer.scissor_stack[renderer.scissor_count] = command.rect
                renderer.scissor_count += 1
            }
        case .Scissor_End:
            if renderer.scissor_count > 0 {
                renderer.scissor_count -= 1
            }
        case:
        }
        renderer.stats.commands_executed += 1
    }
}

renderer_framebuffer_checksum :: proc(renderer: ^Renderer) -> u64 {
    hash: u64 = 1469598103934665603
    for pixel in renderer.framebuffer {
        hash ^= u64(pixel)
        hash *= 1099511628211
    }
    return hash
}

renderer_self_check :: proc() {
    renderer: Renderer
    renderer_begin_frame(&renderer, 1)
    assert(render_push_clear(&renderer.commands, {0.05, 0.08, 0.12, 1}))
    assert(render_push_rect(&renderer.commands, Rect{{10, 10}, {30, 25}}, {1, 0, 0, 1}))
    assert(render_push_line(&renderer.commands, {0, 0}, {40, 40}, {0, 1, 0, 1}))
    assert(render_push_circle(&renderer.commands, {80, 50}, 12, {0, 0.5, 1, 1}))
    renderer_execute(&renderer)
    assert(renderer.stats.commands_executed == 4)
    assert(renderer_framebuffer_checksum(&renderer) != 0)

    pixels := [?]u32{0xffffffff, 0xff0000ff, 0xff00ff00, 0xffff0000}
    texture, result := renderer_create_texture(&renderer, 2, 2, pixels[:])
    assert(result_is_ok(result))
    material, result := renderer_create_material(&renderer, texture, {1, 1, 1, 1}, .Alpha)
    assert(result_is_ok(result))
    assert(renderer_texture_valid(&renderer, texture))
    assert(renderer_material_valid(&renderer, material))
    assert(result_is_ok(renderer_destroy_material(&renderer, material)))
    assert(result_is_ok(renderer_destroy_texture(&renderer, texture)))
}
