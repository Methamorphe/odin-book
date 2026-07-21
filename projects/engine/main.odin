package main

import "core:fmt"

main :: proc() {
    app: App
    app_init(&app)
    defer app_shutdown(&app)

    player_asset, player_registered := register_asset(&app.assets, "player")
    assert(player_registered)
    enemy_asset, enemy_registered := register_asset(&app.assets, "enemy")
    assert(enemy_registered)

    player, player_spawned := spawn_entity(
        &app.world,
        Transform{position = {0, 0}, velocity = {2, 0}},
        player_asset,
    )
    assert(player_spawned)

    enemy, enemy_spawned := spawn_entity(
        &app.world,
        Transform{position = {8, 2}, velocity = {-1, 0}},
        enemy_asset,
    )
    assert(enemy_spawned)

    fixed_dt: f32 = 1.0 / 60.0
    for _ in 0..<5 {
        app_frame(&app, fixed_dt)
    }

    player_transform, player_found := get_transform(&app.world, player)
    assert(player_found)

    fmt.printf(
        "frames=%d entities=%d commands=%d player_x=%.3f\n",
        app.stats.frame_count,
        app.world.count,
        app.renderer.count,
        player_transform.position.x,
    )

    assert(destroy_entity(&app.world, enemy))
    _, stale_enemy_found := get_transform(&app.world, enemy)
    fmt.println("stale enemy handle resolves:", stale_enemy_found)
}