package main

Editor_Command_Kind :: enum {
    None,
    Set_Position,
    Set_Rotation,
    Set_Scale,
    Rename,
    Set_Health,
    Create_Entity,
    Destroy_Entity,
    Reparent,
    Enable,
    Disable,
}

Editor_Command :: struct {
    id: Command_ID,
    kind: Editor_Command_Kind,
    entity: Entity_ID,
    other: Entity_ID,
    persistent_id: u64,
    before_vec2: Vec2,
    after_vec2: Vec2,
    before_f32: f32,
    after_f32: f32,
    before_i32: i32,
    after_i32: i32,
    before_name: Name,
    after_name: Name,
    before_bool: bool,
    after_bool: bool,
}

Editor_Selection :: struct {
    entities: [128]Entity_ID,
    count: int,
    active: Entity_ID,
}

Editor_History :: struct {
    commands: [MAX_HISTORY]Editor_Command,
    count: int,
    cursor: int,
    next_id: u64,
    dropped: u64,
}

Editor_Clipboard_Entity :: struct {
    valid: bool,
    name: Name,
    transform: Transform_2D,
    has_motion: bool,
    motion: Motion,
    has_sprite: bool,
    sprite: Sprite_Component,
    has_collider: bool,
    collider: Collider_Component,
    has_health: bool,
    health: Health_Component,
}

Editor :: struct {
    enabled: bool,
    play_mode: bool,
    selection: Editor_Selection,
    history: Editor_History,
    clipboard: Editor_Clipboard_Entity,
    hovered: Entity_ID,
    scene_dirty: bool,
    save_requested: bool,
    load_requested: bool,
    play_snapshot: [256*1024]u8,
    play_snapshot_size: int,
}

editor_selection_contains :: proc(selection: ^Editor_Selection, entity: Entity_ID) -> bool {
    for selected in selection.entities[:selection.count] {
        if selected == entity { return true }
    }
    return false
}

editor_select :: proc(editor: ^Editor, world: ^World, entity: Entity_ID, additive: bool = false) -> Result {
    if !world_entity_valid(world, entity) {
        return result_error(.Stale_Handle, "cannot select stale entity")
    }
    if !additive {
        editor.selection.count = 0
    }
    if editor_selection_contains(&editor.selection, entity) {
        editor.selection.active = entity
        return result_ok()
    }
    if editor.selection.count >= len(editor.selection.entities) {
        return result_error(.Capacity_Exceeded, "selection capacity exceeded")
    }
    editor.selection.entities[editor.selection.count] = entity
    editor.selection.count += 1
    editor.selection.active = entity
    return result_ok()
}

editor_deselect :: proc(editor: ^Editor, entity: Entity_ID) -> bool {
    for i in 0..<editor.selection.count {
        if editor.selection.entities[i] != entity { continue }
        editor.selection.count -= 1
        editor.selection.entities[i] = editor.selection.entities[editor.selection.count]
        if editor.selection.active == entity {
            editor.selection.active = editor.selection.count > 0 ? editor.selection.entities[editor.selection.count-1] : Entity_ID{}
        }
        return true
    }
    return false
}

editor_clear_selection :: proc(editor: ^Editor) {
    editor.selection.count = 0
    editor.selection.active = {}
}

editor_resolve_command_entity :: proc(world: ^World, command: ^Editor_Command) -> (Entity_ID, bool) {
    if world_entity_valid(world, command.entity) {
        return command.entity, true
    }
    if command.persistent_id != 0 {
        return world_find_persistent(world, command.persistent_id)
    }
    return {}, false
}

editor_apply_command :: proc(editor: ^Editor, world: ^World, command: ^Editor_Command, forward: bool) -> Result {
    entity, found := editor_resolve_command_entity(world, command)
    switch command.kind {
    case .Create_Entity:
        if forward {
            if found { return result_ok() }
            created, result := world_spawn(world, name_string(&command.after_name))
            if !result_is_ok(result) { return result }
            command.entity = created
            command.persistent_id = world.entities[created.index].persistent_id
            return result_ok()
        }
        if !found { return result_ok() }
        return world_destroy(world, entity)
    case .Destroy_Entity:
        if forward {
            if !found { return result_ok() }
            return world_destroy(world, entity)
        }
        created, result := world_spawn(world, name_string(&command.before_name))
        if !result_is_ok(result) { return result }
        command.entity = created
        world.entities[created.index].persistent_id = command.persistent_id
        return result_ok()
    }

    if !found {
        return result_error(.Not_Found, "editor command target no longer exists")
    }

    switch command.kind {
    case .Set_Position:
        transform, result := world_transform(world, entity)
        if !result_is_ok(result) { return result }
        transform.position = forward ? command.after_vec2 : command.before_vec2
    case .Set_Rotation:
        transform, result := world_transform(world, entity)
        if !result_is_ok(result) { return result }
        transform.rotation = forward ? command.after_f32 : command.before_f32
    case .Set_Scale:
        transform, result := world_transform(world, entity)
        if !result_is_ok(result) { return result }
        transform.scale = forward ? command.after_vec2 : command.before_vec2
    case .Rename:
        name := forward ? command.after_name : command.before_name
        return world_add_name(world, entity, name_string(&name))
    case .Set_Health:
        health, result := world_health_component(world, entity)
        if !result_is_ok(result) { return result }
        health.current = clamp(forward ? command.after_i32 : command.before_i32, 0, health.maximum)
    case .Reparent:
        parent := forward ? command.other : Entity_ID{}
        return world_set_parent(world, entity, parent)
    case .Enable:
        world.entities[entity.index].enabled = forward ? true : command.before_bool
    case .Disable:
        world.entities[entity.index].enabled = forward ? false : command.before_bool
    case:
    }
    editor.scene_dirty = true
    return result_ok()
}

editor_execute :: proc(editor: ^Editor, world: ^World, command: Editor_Command) -> Result {
    if editor.history.cursor < editor.history.count {
        editor.history.count = editor.history.cursor
    }
    if editor.history.count >= len(editor.history.commands) {
        copy(editor.history.commands[0:len(editor.history.commands)-1], editor.history.commands[1:])
        editor.history.count -= 1
        editor.history.cursor = editor.history.count
        editor.history.dropped += 1
    }
    command.id = Command_ID{editor.history.next_id}
    editor.history.next_id += 1
    result := editor_apply_command(editor, world, &command, true)
    if !result_is_ok(result) { return result }
    editor.history.commands[editor.history.count] = command
    editor.history.count += 1
    editor.history.cursor = editor.history.count
    editor.scene_dirty = true
    return result_ok()
}

editor_undo :: proc(editor: ^Editor, world: ^World) -> Result {
    if editor.history.cursor == 0 {
        return result_error(.Not_Found, "nothing to undo")
    }
    editor.history.cursor -= 1
    command := &editor.history.commands[editor.history.cursor]
    result := editor_apply_command(editor, world, command, false)
    if !result_is_ok(result) {
        editor.history.cursor += 1
        return result
    }
    editor.scene_dirty = true
    return result_ok()
}

editor_redo :: proc(editor: ^Editor, world: ^World) -> Result {
    if editor.history.cursor >= editor.history.count {
        return result_error(.Not_Found, "nothing to redo")
    }
    command := &editor.history.commands[editor.history.cursor]
    result := editor_apply_command(editor, world, command, true)
    if !result_is_ok(result) { return result }
    editor.history.cursor += 1
    editor.scene_dirty = true
    return result_ok()
}

editor_command_set_position :: proc(world: ^World, entity: Entity_ID, value: Vec2) -> (Editor_Command, Result) {
    transform, result := world_transform(world, entity)
    if !result_is_ok(result) { return {}, result }
    return Editor_Command{
        kind = .Set_Position,
        entity = entity,
        persistent_id = world.entities[entity.index].persistent_id,
        before_vec2 = transform.position,
        after_vec2 = value,
    }, result_ok()
}

editor_command_rename :: proc(world: ^World, entity: Entity_ID, value: string) -> (Editor_Command, Result) {
    if !world_entity_valid(world, entity) { return {}, result_error(.Stale_Handle, "invalid entity") }
    before, ok := name_from_string(world_name(world, entity))
    if !ok { return {}, result_error(.Invalid_State, "existing name is invalid") }
    after, ok := name_from_string(value)
    if !ok { return {}, result_error(.Invalid_Argument, "new name is too long") }
    return Editor_Command{
        kind = .Rename,
        entity = entity,
        persistent_id = world.entities[entity.index].persistent_id,
        before_name = before,
        after_name = after,
    }, result_ok()
}

editor_copy_entity :: proc(editor: ^Editor, world: ^World, entity: Entity_ID) -> Result {
    if !world_entity_valid(world, entity) { return result_error(.Stale_Handle, "invalid entity") }
    clip: Editor_Clipboard_Entity
    clip.valid = true
    if dense_set_contains(&world.name_set, entity.index) { clip.name = world.names[entity.index] }
    if dense_set_contains(&world.transform_set, entity.index) { clip.transform = world.transforms[entity.index] }
    if dense_set_contains(&world.motion_set, entity.index) { clip.has_motion = true; clip.motion = world.motions[entity.index] }
    if dense_set_contains(&world.sprite_set, entity.index) { clip.has_sprite = true; clip.sprite = world.sprites[entity.index] }
    if dense_set_contains(&world.collider_set, entity.index) { clip.has_collider = true; clip.collider = world.colliders[entity.index] }
    if dense_set_contains(&world.health_set, entity.index) { clip.has_health = true; clip.health = world.health[entity.index] }
    editor.clipboard = clip
    return result_ok()
}

editor_paste_entity :: proc(editor: ^Editor, world: ^World, offset: Vec2 = {1, 1}) -> (Entity_ID, Result) {
    if !editor.clipboard.valid { return {}, result_error(.Not_Found, "clipboard is empty") }
    label := name_string(&editor.clipboard.name)
    entity, result := world_spawn(world, label)
    if !result_is_ok(result) { return {}, result }
    world.transforms[entity.index] = editor.clipboard.transform
    world.transforms[entity.index].position = vec2_add(world.transforms[entity.index].position, offset)
    if editor.clipboard.has_motion { _ = world_add_motion(world, entity, editor.clipboard.motion) }
    if editor.clipboard.has_sprite { _ = world_add_sprite(world, entity, editor.clipboard.sprite) }
    if editor.clipboard.has_collider { _ = world_add_collider(world, entity, editor.clipboard.collider) }
    if editor.clipboard.has_health { _ = world_add_health(world, entity, editor.clipboard.health) }
    editor.scene_dirty = true
    return entity, result_ok()
}

editor_validate :: proc(editor: ^Editor, world: ^World) -> bool {
    if editor.history.cursor < 0 || editor.history.cursor > editor.history.count || editor.history.count > len(editor.history.commands) {
        return false
    }
    for entity in editor.selection.entities[:editor.selection.count] {
        if !world_entity_valid(world, entity) { return false }
    }
    if editor.selection.active != Entity_ID{} && !editor_selection_contains(&editor.selection, editor.selection.active) {
        return false
    }
    return true
}

editor_self_check :: proc() {
    world: World
    assert(result_is_ok(world_init(&world, Rect{{-10, -10}, {10, 10}})))
    entity, result := world_spawn(&world, "box")
    assert(result_is_ok(result))
    editor: Editor
    assert(result_is_ok(editor_select(&editor, &world, entity)))
    command, result := editor_command_set_position(&world, entity, {4, 5})
    assert(result_is_ok(result))
    assert(result_is_ok(editor_execute(&editor, &world, command)))
    assert(world.transforms[entity.index].position == Vec2{4, 5})
    assert(result_is_ok(editor_undo(&editor, &world)))
    assert(world.transforms[entity.index].position == Vec2{})
    assert(result_is_ok(editor_redo(&editor, &world)))
    assert(editor_validate(&editor, &world))
}
