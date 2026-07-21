package main

App :: struct {
    initialized: bool,
    world:       World,
    assets:      Asset_Registry,
    renderer:    Renderer,
    stats:       Frame_Stats,
}

app_init :: proc(app: ^App) {
    assert(!app.initialized)
    app.initialized = true
}

app_frame :: proc(app: ^App, dt: f32) {
    assert(app.initialized)

    begin_render_frame(&app.renderer)
    update_world(&app.world, dt)
    app.stats.simulation_steps += 1

    extract_render_commands(&app.renderer, &app.world)
    app.stats.extracted_commands += u64(app.renderer.count)

    submitted := submit_render_commands(&app.renderer)
    app.stats.submitted_commands += u64(submitted)
    app.stats.frame_count += 1
}

app_shutdown :: proc(app: ^App) {
    assert(app.initialized)
    app.initialized = false
}