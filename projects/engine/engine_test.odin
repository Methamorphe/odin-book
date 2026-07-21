package main

import "core:testing"

@(test)
entity_handles_reject_stale_references :: proc(t: ^testing.T) {
    world: World
    entity, created := spawn_entity(&world, Transform{}, Asset_Handle{})
    testing.expect(t, created)
    testing.expect(t, entity_valid(&world, entity))
    testing.expect(t, destroy_entity(&world, entity))
    testing.expect(t, !entity_valid(&world, entity))

    replacement, replacement_created := spawn_entity(&world, Transform{}, Asset_Handle{})
    testing.expect(t, replacement_created)
    testing.expect(t, replacement.index == entity.index)
    testing.expect(t, replacement.generation != entity.generation)
}

@(test)
frame_pipeline_updates_and_extracts :: proc(t: ^testing.T) {
    app: App
    app_init(&app)

    asset, registered := register_asset(&app.assets, "test")
    testing.expect(t, registered)

    entity, spawned := spawn_entity(
        &app.world,
        Transform{position = {0, 0}, velocity = {4, 0}},
        asset,
    )
    testing.expect(t, spawned)

    app_frame(&app, 0.5)

    transform, found := get_transform(&app.world, entity)
    testing.expect(t, found)
    testing.expect(t, transform.position.x == 2)
    testing.expect(t, app.stats.frame_count == 1)
    testing.expect(t, app.renderer.count == 1)

    app_shutdown(&app)
    testing.expect(t, !app.initialized)
}