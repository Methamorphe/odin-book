package main

import "core:fmt"

State :: enum { Empty, Loading, Ready, Failed }
Handle :: struct { index, generation: u32 }
Resource :: struct { generation: u32, state: State, name: string, references: u32 }
Registry :: struct { resources: [64]Resource }

acquire :: proc(r: ^Registry, name: string) -> (Handle, bool) {
    for i in 0..<len(r.resources) {
        slot := &r.resources[i]
        if slot.state == .Empty {
            if slot.generation == 0 { slot.generation = 1 }
            slot.state = .Loading
            slot.name = name
            slot.references = 1
            return Handle{u32(i), slot.generation}, true
        }
    }
    return {}, false
}

resolve :: proc(r: ^Registry, h: Handle) -> (^Resource, bool) {
    if h.index >= u32(len(r.resources)) { return nil, false }
    slot := &r.resources[h.index]
    if slot.state == .Empty || slot.generation != h.generation { return nil, false }
    return slot, true
}

release :: proc(r: ^Registry, h: Handle) -> bool {
    slot, ok := resolve(r, h)
    if !ok { return false }
    if slot.references > 1 { slot.references -= 1; return true }
    slot.state = .Empty
    slot.name = ""
    slot.references = 0
    slot.generation += 1
    if slot.generation == 0 { slot.generation = 1 }
    return true
}

main :: proc() {
    registry: Registry
    h, ok := acquire(&registry, "hero.mesh")
    assert(ok)
    resource, ok := resolve(&registry, h)
    assert(ok)
    resource.state = .Ready
    fmt.println(resource.name, resource.state)
    assert(release(&registry, h))
    _, stale := resolve(&registry, h)
    assert(!stale)
}
