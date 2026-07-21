package main

Asset_Registry :: struct {
    generations: [MAX_ASSETS]u32,
    occupied:    [MAX_ASSETS]bool,
    names:       [MAX_ASSETS]string,
    count:       int,
}

asset_valid :: proc(registry: ^Asset_Registry, handle: Asset_Handle) -> bool {
    index := int(handle.index)
    if index < 0 || index >= MAX_ASSETS {
        return false
    }
    return registry.occupied[index] && registry.generations[index] == handle.generation
}

register_asset :: proc(registry: ^Asset_Registry, name: string) -> (Asset_Handle, bool) {
    for index in 0..<MAX_ASSETS {
        if registry.occupied[index] {
            continue
        }
        registry.occupied[index] = true
        registry.names[index] = name
        registry.count += 1
        return Asset_Handle{index = u32(index), generation = registry.generations[index]}, true
    }
    return Asset_Handle{}, false
}

asset_name :: proc(registry: ^Asset_Registry, handle: Asset_Handle) -> (string, bool) {
    if !asset_valid(registry, handle) {
        return "", false
    }
    return registry.names[int(handle.index)], true
}