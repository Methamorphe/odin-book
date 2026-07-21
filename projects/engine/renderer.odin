package main

Renderer :: struct {
    commands: [MAX_RENDER_COMMANDS]Render_Command,
    count:    int,
}

begin_render_frame :: proc(renderer: ^Renderer) {
    renderer.count = 0
}

extract_render_commands :: proc(renderer: ^Renderer, world: ^World) {
    for index in 0..<MAX_ENTITIES {
        if !world.alive[index] || renderer.count >= MAX_RENDER_COMMANDS {
            continue
        }

        renderer.commands[renderer.count] = Render_Command{
            entity = Entity{index = u32(index), generation = world.generations[index]},
            asset = world.assets[index],
            position = world.transforms[index].position,
        }
        renderer.count += 1
    }
}

submit_render_commands :: proc(renderer: ^Renderer) -> int {
    return renderer.count
}