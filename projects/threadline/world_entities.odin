package main

Component :: enum u8 {
    Transform,
    Motion,
    Sprite,
    Collider,
    Health,
    Lifetime,
    Player,
    Enemy,
    Camera,
    Name,
}

Component_Mask :: bit_set[Component]

Entity_Record :: struct {
    generation: u32,
    alive: bool,
    enabled: bool,
    components: Component_Mask,
    parent: Entity_ID,
    first_child: Entity_ID,
    next_sibling: Entity_ID,
    persistent_id: u64,
}

World_Stats :: struct {
    spawned: u64,
    destroyed: u64,
    alive: int,
    peak_alive: int,
    fixed_updates: u64,
    variable_updates: u64,
    render_extractions: u64,
    stale_accesses: u64,
}

World :: struct {
    entities: [MAX_ENTITIES]Entity_Record,
    free_indices: Index_Queue,
    next_unused: u32,
    transforms: [MAX_ENTITIES]Transform_2D,
    motions: [MAX_ENTITIES]Motion,
    sprites: [MAX_ENTITIES]Sprite_Component,
    colliders: [MAX_ENTITIES]Collider_Component,
    health: [MAX_ENTITIES]Health_Component,
    lifetimes: [MAX_ENTITIES]Lifetime_Component,
    players: [MAX_ENTITIES]Player_Component,
    enemies: [MAX_ENTITIES]Enemy_Component,
    cameras: [MAX_ENTITIES]Camera_Component,
    names: [MAX_ENTITIES]Name,
    transform_set: Dense_Index_Set,
    motion_set: Dense_Index_Set,
    sprite_set: Dense_Index_Set,
    collider_set: Dense_Index_Set,
    health_set: Dense_Index_Set,
    lifetime_set: Dense_Index_Set,
    player_set: Dense_Index_Set,
    enemy_set: Dense_Index_Set,
    camera_set: Dense_Index_Set,
    name_set: Dense_Index_Set,
    next_persistent_id: u64,
    active_camera: Entity_ID,
    bounds: Rect,
    paused: bool,
    stats: World_Stats,
}

world_init :: proc(world: ^World, bounds: Rect) -> Result {
    if rect_width(bounds) <= 0 || rect_height(bounds) <= 0 {
        return result_error(.Invalid_Argument, "world bounds must be positive")
    }
    world^ = World{bounds = bounds, next_persistent_id = 1}
    return result_ok()
}

world_entity_valid :: proc(world: ^World, entity: Entity_ID) -> bool {
    if entity.index >= MAX_ENTITIES {
        return false
    }
    record := &world.entities[entity.index]
    return record.alive && record.generation == entity.generation
}

world_spawn :: proc(world: ^World, label: string = "entity") -> (Entity_ID, Result) {
    index: u32
    if free, ok := index_queue_pop(&world.free_indices); ok {
        index = free
    } else {
        if world.next_unused >= MAX_ENTITIES {
            return {}, result_error(.Capacity_Exceeded, "world entity capacity exceeded")
        }
        index = world.next_unused
        world.next_unused += 1
    }

    record := &world.entities[index]
    if record.generation == 0 {
        record.generation = 1
    }
    record.alive = true
    record.enabled = true
    record.components = {}
    record.parent = {}
    record.first_child = {}
    record.next_sibling = {}
    record.persistent_id = world.next_persistent_id
    world.next_persistent_id += 1

    entity := Entity_ID{index, record.generation}
    world.stats.spawned += 1
    world.stats.alive += 1
    world.stats.peak_alive = max(world.stats.peak_alive, world.stats.alive)

    result := world_add_transform(world, entity, Transform_2D{scale = {1, 1}})
    if !result_is_ok(result) {
        _ = world_destroy(world, entity)
        return {}, result
    }
    if len(label) > 0 {
        _ = world_add_name(world, entity, label)
    }
    return entity, result_ok()
}

world_detach_from_parent :: proc(world: ^World, entity: Entity_ID) {
    if !world_entity_valid(world, entity) {
        return
    }
    record := &world.entities[entity.index]
    parent := record.parent
    if !world_entity_valid(world, parent) {
        record.parent = {}
        return
    }
    parent_record := &world.entities[parent.index]
    child := parent_record.first_child
    previous: Entity_ID
    for world_entity_valid(world, child) {
        child_record := &world.entities[child.index]
        if child == entity {
            if world_entity_valid(world, previous) {
                world.entities[previous.index].next_sibling = child_record.next_sibling
            } else {
                parent_record.first_child = child_record.next_sibling
            }
            record.parent = {}
            record.next_sibling = {}
            return
        }
        previous = child
        child = child_record.next_sibling
    }
}

world_set_parent :: proc(world: ^World, child, parent: Entity_ID) -> Result {
    if !world_entity_valid(world, child) {
        return result_error(.Stale_Handle, "invalid child entity")
    }
    if parent != Entity_ID{} && !world_entity_valid(world, parent) {
        return result_error(.Stale_Handle, "invalid parent entity")
    }
    if child == parent {
        return result_error(.Invalid_Argument, "entity cannot parent itself")
    }
    ancestor := parent
    for world_entity_valid(world, ancestor) {
        if ancestor == child {
            return result_error(.Invalid_Argument, "scene hierarchy cycle")
        }
        ancestor = world.entities[ancestor.index].parent
    }
    world_detach_from_parent(world, child)
    if parent == Entity_ID{} {
        return result_ok()
    }
    child_record := &world.entities[child.index]
    parent_record := &world.entities[parent.index]
    child_record.parent = parent
    child_record.next_sibling = parent_record.first_child
    parent_record.first_child = child
    return result_ok()
}

world_remove_all_components :: proc(world: ^World, entity: Entity_ID) {
    index := entity.index
    _ = dense_set_remove(&world.transform_set, index)
    _ = dense_set_remove(&world.motion_set, index)
    _ = dense_set_remove(&world.sprite_set, index)
    _ = dense_set_remove(&world.collider_set, index)
    _ = dense_set_remove(&world.health_set, index)
    _ = dense_set_remove(&world.lifetime_set, index)
    _ = dense_set_remove(&world.player_set, index)
    _ = dense_set_remove(&world.enemy_set, index)
    _ = dense_set_remove(&world.camera_set, index)
    _ = dense_set_remove(&world.name_set, index)
    world.entities[index].components = {}
}

world_destroy :: proc(world: ^World, entity: Entity_ID) -> Result {
    if !world_entity_valid(world, entity) {
        world.stats.stale_accesses += 1
        return result_error(.Stale_Handle, "invalid entity handle")
    }
    child := world.entities[entity.index].first_child
    for world_entity_valid(world, child) {
        next := world.entities[child.index].next_sibling
        world.entities[child.index].parent = {}
        world.entities[child.index].next_sibling = {}
        child = next
    }
    world_detach_from_parent(world, entity)
    world_remove_all_components(world, entity)
    record := &world.entities[entity.index]
    record.alive = false
    record.enabled = false
    record.generation = next_generation(record.generation)
    record.parent = {}
    record.first_child = {}
    record.next_sibling = {}
    record.persistent_id = 0
    if !index_queue_push(&world.free_indices, entity.index) {
        return result_error(.Invalid_State, "entity free queue overflow")
    }
    if world.active_camera == entity {
        world.active_camera = {}
    }
    world.stats.destroyed += 1
    world.stats.alive -= 1
    return result_ok()
}

world_find_persistent :: proc(world: ^World, persistent_id: u64) -> (Entity_ID, bool) {
    if persistent_id == 0 { return {}, false }
    for i in 0..<int(world.next_unused) {
        record := &world.entities[i]
        if record.alive && record.persistent_id == persistent_id {
            return Entity_ID{u32(i), record.generation}, true
        }
    }
    return {}, false
}
