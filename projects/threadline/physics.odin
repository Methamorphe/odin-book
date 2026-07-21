package main

MAX_CONTACTS :: 4096

Contact :: struct {
    a: Entity_ID,
    b: Entity_ID,
    normal: Vec2,
    penetration: f32,
    trigger: bool,
}

Physics_Stats :: struct {
    candidates: u64,
    contacts: u64,
    resolved: u64,
    triggers: u64,
    dropped: u64,
}

Physics_World :: struct {
    contacts: [MAX_CONTACTS]Contact,
    contact_count: int,
    stats: Physics_Stats,
}

collider_aabb :: proc(world: ^World, entity_index: u32) -> AABB {
    transform := world.transforms[entity_index]
    collider := world.colliders[entity_index]
    center := vec2_add(transform.position, collider.offset)
    return AABB{
        min = vec2_sub(center, collider.half_extents),
        max = vec2_add(center, collider.half_extents),
    }
}

collision_layers_match :: proc(a, b: Collider_Component) -> bool {
    return (a.mask & b.layer) != 0 && (b.mask & a.layer) != 0
}

contact_from_aabbs :: proc(a_entity, b_entity: Entity_ID, a, b: AABB, trigger: bool) -> (Contact, bool) {
    if !aabb_overlaps(a, b) { return {}, false }
    overlap_left := a.max.x-b.min.x
    overlap_right := b.max.x-a.min.x
    overlap_down := a.max.y-b.min.y
    overlap_up := b.max.y-a.min.y
    penetration_x := min(overlap_left, overlap_right)
    penetration_y := min(overlap_down, overlap_up)
    contact := Contact{a = a_entity, b = b_entity, trigger = trigger}
    if penetration_x < penetration_y {
        contact.penetration = penetration_x
        contact.normal = a.min.x < b.min.x ? Vec2{-1, 0} : Vec2{1, 0}
    } else {
        contact.penetration = penetration_y
        contact.normal = a.min.y < b.min.y ? Vec2{0, -1} : Vec2{0, 1}
    }
    return contact, true
}

physics_begin_step :: proc(physics: ^Physics_World) {
    physics.contact_count = 0
    physics.stats.candidates = 0
    physics.stats.contacts = 0
    physics.stats.resolved = 0
    physics.stats.triggers = 0
    physics.stats.dropped = 0
}

physics_push_contact :: proc(physics: ^Physics_World, contact: Contact) -> bool {
    if physics.contact_count >= len(physics.contacts) {
        physics.stats.dropped += 1
        return false
    }
    physics.contacts[physics.contact_count] = contact
    physics.contact_count += 1
    physics.stats.contacts += 1
    if contact.trigger { physics.stats.triggers += 1 }
    return true
}

physics_generate_contacts :: proc(physics: ^Physics_World, world: ^World) {
    for dense_a in 0..<world.collider_set.count {
        index_a := world.collider_set.dense[dense_a]
        if !world.entities[index_a].enabled || !dense_set_contains(&world.transform_set, index_a) { continue }
        collider_a := world.colliders[index_a]
        aabb_a := collider_aabb(world, index_a)
        for dense_b in dense_a+1..<world.collider_set.count {
            index_b := world.collider_set.dense[dense_b]
            if !world.entities[index_b].enabled || !dense_set_contains(&world.transform_set, index_b) { continue }
            collider_b := world.colliders[index_b]
            if !collision_layers_match(collider_a, collider_b) { continue }
            physics.stats.candidates += 1
            aabb_b := collider_aabb(world, index_b)
            a := Entity_ID{index_a, world.entities[index_a].generation}
            b := Entity_ID{index_b, world.entities[index_b].generation}
            contact, found := contact_from_aabbs(a, b, aabb_a, aabb_b, collider_a.trigger || collider_b.trigger)
            if found { _ = physics_push_contact(physics, contact) }
        }
    }
}

physics_resolve_contact :: proc(physics: ^Physics_World, world: ^World, contact: Contact) {
    if contact.trigger || !world_entity_valid(world, contact.a) || !world_entity_valid(world, contact.b) { return }
    a_movable := dense_set_contains(&world.motion_set, contact.a.index)
    b_movable := dense_set_contains(&world.motion_set, contact.b.index)
    if !a_movable && !b_movable { return }
    correction := vec2_scale(contact.normal, contact.penetration)
    if a_movable && b_movable {
        world.transforms[contact.a.index].position = vec2_add(world.transforms[contact.a.index].position, vec2_scale(correction, 0.5))
        world.transforms[contact.b.index].position = vec2_sub(world.transforms[contact.b.index].position, vec2_scale(correction, 0.5))
    } else if a_movable {
        world.transforms[contact.a.index].position = vec2_add(world.transforms[contact.a.index].position, correction)
    } else {
        world.transforms[contact.b.index].position = vec2_sub(world.transforms[contact.b.index].position, correction)
    }
    if a_movable {
        velocity := &world.motions[contact.a.index].velocity
        along_normal := vec2_dot(velocity^, contact.normal)
        if along_normal < 0 { velocity^ = vec2_sub(velocity^, vec2_scale(contact.normal, along_normal)) }
    }
    if b_movable {
        inverse_normal := vec2_scale(contact.normal, -1)
        velocity := &world.motions[contact.b.index].velocity
        along_normal := vec2_dot(velocity^, inverse_normal)
        if along_normal < 0 { velocity^ = vec2_sub(velocity^, vec2_scale(inverse_normal, along_normal)) }
    }
    physics.stats.resolved += 1
}

physics_step :: proc(physics: ^Physics_World, world: ^World) {
    physics_begin_step(physics)
    physics_generate_contacts(physics, world)
    for contact in physics.contacts[:physics.contact_count] {
        physics_resolve_contact(physics, world, contact)
    }
}

physics_contacts_entity :: proc(physics: ^Physics_World, entity: Entity_ID, output: []Contact) -> int {
    count := 0
    for contact in physics.contacts[:physics.contact_count] {
        if contact.a != entity && contact.b != entity { continue }
        if count >= len(output) { break }
        output[count] = contact
        count += 1
    }
    return count
}

physics_self_check :: proc() {
    world: World
    assert(result_is_ok(world_init(&world, Rect{{-10, -10}, {10, 10}})))
    a, result := world_spawn(&world, "a")
    assert(result_is_ok(result))
    b, result := world_spawn(&world, "b")
    assert(result_is_ok(result))
    world.transforms[a.index].position = {0, 0}
    world.transforms[b.index].position = {1, 0}
    assert(result_is_ok(world_add_motion(&world, a, Motion{})))
    assert(result_is_ok(world_add_collider(&world, a, Collider_Component{half_extents = {1, 1}, layer = 1, mask = 1})))
    assert(result_is_ok(world_add_collider(&world, b, Collider_Component{half_extents = {1, 1}, layer = 1, mask = 1})))
    physics: Physics_World
    physics_step(&physics, &world)
    assert(physics.contact_count == 1)
    assert(physics.stats.resolved == 1)
}
