package main

import "core:fmt"

CAPACITY :: 4

Asset_State :: enum {
    Unloaded,
    Ready,
    Failed,
}

Texture_Handle :: struct {
    index: int,
    generation: u32,
}

Texture_Record :: struct {
    generation: u32,
    alive: bool,
    state: Asset_State,
    version: u32,
    references: int,
    name: string,
}

Registry :: struct {
    records: [CAPACITY]Texture_Record,
}

create_texture :: proc(registry: ^Registry, name: string) -> (Texture_Handle, bool) {
    for i in 0..<CAPACITY {
        record := &registry.records[i]
        if !record.alive {
            record.alive = true
            record.state = .Ready
            record.version = 1
            record.references = 1
            record.name = name
            return Texture_Handle{index = i, generation = record.generation}, true
        }
    }
    return {}, false
}

resolve :: proc(registry: ^Registry, handle: Texture_Handle) -> (^Texture_Record, bool) {
    if handle.index < 0 || handle.index >= CAPACITY {
        return nil, false
    }
    record := &registry.records[handle.index]
    if !record.alive || record.generation != handle.generation {
        return nil, false
    }
    return record, true
}

reload :: proc(registry: ^Registry, handle: Texture_Handle) -> bool {
    record, ok := resolve(registry, handle)
    if !ok {
        return false
    }
    record.version += 1
    record.state = .Ready
    return true
}

main :: proc() {
    registry: Registry
    texture, ok := create_texture(&registry, "textures/stone")
    assert(ok)
    assert(reload(&registry, texture))

    record, found := resolve(&registry, texture)
    assert(found)
    fmt.println("asset:", record.name)
    fmt.println("version:", record.version)
    fmt.println("references:", record.references)
}
