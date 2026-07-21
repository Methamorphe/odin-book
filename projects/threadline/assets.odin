package main

Asset_Type :: enum {
    Unknown,
    Texture,
    Mesh,
    Material,
    Audio,
    Scene,
    Font,
    Script_Data,
}

Asset_State :: enum {
    Empty,
    Registered,
    Queued,
    Loading,
    Ready,
    Failed,
    Unloading,
}

Asset_Dependency :: struct {
    key: Asset_Key,
    required: bool,
}

Asset_Record :: struct {
    generation: u32,
    key: Asset_Key,
    asset_type: Asset_Type,
    state: Asset_State,
    source_path: Path,
    artifact_path: Path,
    name: Name,
    source_hash: u64,
    artifact_hash: u64,
    importer_version: u32,
    schema_version: u32,
    payload_offset: u32,
    payload_size: u32,
    reference_count: u32,
    dependency_begin: u16,
    dependency_count: u16,
    last_error: Engine_Error,
    last_used_frame: u64,
}

Asset_Request :: struct {
    id: Asset_ID,
    priority: u8,
}

Asset_Manifest_Entry :: struct {
    key: Asset_Key,
    asset_type: Asset_Type,
    artifact_hash: u64,
    artifact_size: u32,
    schema_version: u32,
}

Asset_Manifest :: struct {
    entries: [MAX_ASSETS]Asset_Manifest_Entry,
    count: int,
    build_hash: u64,
    schema_version: u32,
}

Asset_Registry :: struct {
    records: [MAX_ASSETS]Asset_Record,
    key_to_index: U64_Map,
    dependencies: [4096]Asset_Dependency,
    dependency_count: int,
    requests: [MAX_ASSETS]Asset_Request,
    request_count: int,
    payload: [2*1024*1024]u8,
    payload_count: int,
    loaded_count: int,
    failed_count: int,
    manifest: Asset_Manifest,
}

asset_valid :: proc(registry: ^Asset_Registry, id: Asset_ID) -> bool {
    if id.index >= MAX_ASSETS {
        return false
    }
    record := &registry.records[id.index]
    return record.state != .Empty && record.generation == id.generation
}

asset_find :: proc(registry: ^Asset_Registry, key: Asset_Key) -> (Asset_ID, bool) {
    index, found := u64_map_get(&registry.key_to_index, key.value)
    if !found || index >= MAX_ASSETS {
        return {}, false
    }
    record := &registry.records[index]
    if record.state == .Empty || record.key != key {
        return {}, false
    }
    return Asset_ID{u32(index), record.generation}, true
}

asset_register :: proc(
    registry: ^Asset_Registry,
    source: string,
    artifact: string,
    label: string,
    asset_type: Asset_Type,
    importer_version: u32,
    schema_version: u32,
) -> (Asset_ID, Result) {
    source_path, ok := path_from_string(source)
    if !ok {
        return {}, result_error(.Invalid_Argument, "asset source path is too long")
    }
    artifact_path, ok := path_from_string(artifact)
    if !ok {
        return {}, result_error(.Invalid_Argument, "asset artifact path is too long")
    }
    name, ok := name_from_string(label)
    if !ok {
        return {}, result_error(.Invalid_Argument, "asset name is too long")
    }
    key := asset_key_from_path(&source_path)
    if existing, found := asset_find(registry, key); found {
        return existing, result_ok()
    }

    for i in 0..<len(registry.records) {
        record := &registry.records[i]
        if record.state == .Empty {
            if record.generation == 0 {
                record.generation = 1
            }
            record.key = key
            record.asset_type = asset_type
            record.state = .Registered
            record.source_path = source_path
            record.artifact_path = artifact_path
            record.name = name
            record.importer_version = importer_version
            record.schema_version = schema_version
            _, map_result := u64_map_put(&registry.key_to_index, key.value, u64(i))
            if !result_is_ok(map_result) {
                record.state = .Empty
                return {}, map_result
            }
            return Asset_ID{u32(i), record.generation}, result_ok()
        }
    }
    return {}, result_error(.Capacity_Exceeded, "asset registry exhausted")
}

asset_add_dependency :: proc(registry: ^Asset_Registry, id: Asset_ID, dependency: Asset_Key, required: bool = true) -> Result {
    if !asset_valid(registry, id) {
        return result_error(.Stale_Handle, "invalid asset handle")
    }
    if registry.dependency_count >= len(registry.dependencies) {
        return result_error(.Capacity_Exceeded, "asset dependency storage exhausted")
    }
    record := &registry.records[id.index]
    if record.dependency_count == 0 {
        record.dependency_begin = u16(registry.dependency_count)
    } else if int(record.dependency_begin)+int(record.dependency_count) != registry.dependency_count {
        return result_error(.Invalid_State, "dependencies must be registered contiguously")
    }
    registry.dependencies[registry.dependency_count] = Asset_Dependency{dependency, required}
    registry.dependency_count += 1
    record.dependency_count += 1
    return result_ok()
}

asset_dependencies_ready :: proc(registry: ^Asset_Registry, id: Asset_ID) -> (bool, Result) {
    if !asset_valid(registry, id) {
        return false, result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    begin := int(record.dependency_begin)
    end := begin+int(record.dependency_count)
    for dependency in registry.dependencies[begin:end] {
        dependency_id, found := asset_find(registry, dependency.key)
        if !found {
            if dependency.required {
                return false, result_error(.Dependency_Failed, "required dependency is not registered")
            }
            continue
        }
        dependency_record := &registry.records[dependency_id.index]
        if dependency_record.state == .Failed && dependency.required {
            return false, result_error(.Dependency_Failed, "required dependency failed")
        }
        if dependency_record.state != .Ready && dependency.required {
            return false, result_ok()
        }
    }
    return true, result_ok()
}

asset_queue :: proc(registry: ^Asset_Registry, id: Asset_ID, priority: u8 = 128) -> Result {
    if !asset_valid(registry, id) {
        return result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    if record.state == .Ready || record.state == .Loading || record.state == .Queued {
        return result_ok()
    }
    if record.state != .Registered && record.state != .Failed {
        return result_error(.Invalid_State, "asset cannot be queued from current state")
    }
    if registry.request_count >= len(registry.requests) {
        return result_error(.Capacity_Exceeded, "asset request queue exhausted")
    }
    record.state = .Queued
    registry.requests[registry.request_count] = Asset_Request{id, priority}
    registry.request_count += 1
    return result_ok()
}

asset_pop_request :: proc(registry: ^Asset_Registry) -> (Asset_Request, bool) {
    if registry.request_count == 0 {
        return {}, false
    }
    best := 0
    for i in 1..<registry.request_count {
        if registry.requests[i].priority > registry.requests[best].priority {
            best = i
        }
    }
    request := registry.requests[best]
    registry.request_count -= 1
    registry.requests[best] = registry.requests[registry.request_count]
    return request, true
}

asset_begin_load :: proc(registry: ^Asset_Registry, request: Asset_Request) -> Result {
    if !asset_valid(registry, request.id) {
        return result_error(.Stale_Handle, "asset request became stale")
    }
    record := &registry.records[request.id.index]
    if record.state != .Queued {
        return result_error(.Invalid_State, "asset is not queued")
    }
    ready, dependency_result := asset_dependencies_ready(registry, request.id)
    if !result_is_ok(dependency_result) {
        record.state = .Failed
        record.last_error = dependency_result.error
        registry.failed_count += 1
        return dependency_result
    }
    if !ready {
        record.state = .Registered
        return asset_queue(registry, request.id, request.priority)
    }
    record.state = .Loading
    return result_ok()
}

asset_complete_load :: proc(registry: ^Asset_Registry, id: Asset_ID, payload: []u8, source_hash, artifact_hash: u64) -> Result {
    if !asset_valid(registry, id) {
        return result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    if record.state != .Loading {
        return result_error(.Invalid_State, "asset is not loading")
    }
    if registry.payload_count+len(payload) > len(registry.payload) {
        record.state = .Failed
        record.last_error = .Capacity_Exceeded
        registry.failed_count += 1
        return result_error(.Capacity_Exceeded, "asset payload storage exhausted")
    }
    offset := registry.payload_count
    if len(payload) > 0 {
        copy(registry.payload[offset:offset+len(payload)], payload)
    }
    registry.payload_count += len(payload)
    record.payload_offset = u32(offset)
    record.payload_size = u32(len(payload))
    record.source_hash = source_hash
    record.artifact_hash = artifact_hash
    record.state = .Ready
    record.last_error = .None
    registry.loaded_count += 1
    return result_ok()
}

asset_fail_load :: proc(registry: ^Asset_Registry, id: Asset_ID, error: Engine_Error) -> Result {
    if !asset_valid(registry, id) {
        return result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    if record.state != .Loading && record.state != .Queued {
        return result_error(.Invalid_State, "asset is not loading")
    }
    record.state = .Failed
    record.last_error = error
    registry.failed_count += 1
    return result_ok()
}

asset_acquire :: proc(registry: ^Asset_Registry, id: Asset_ID, frame: u64) -> (^Asset_Record, Result) {
    if !asset_valid(registry, id) {
        return nil, result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    if record.state != .Ready {
        return nil, result_error(.Invalid_State, "asset is not ready")
    }
    record.reference_count += 1
    record.last_used_frame = frame
    return record, result_ok()
}

asset_release :: proc(registry: ^Asset_Registry, id: Asset_ID) -> Result {
    if !asset_valid(registry, id) {
        return result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    if record.reference_count == 0 {
        return result_error(.Invalid_State, "asset reference count is already zero")
    }
    record.reference_count -= 1
    return result_ok()
}

asset_payload :: proc(registry: ^Asset_Registry, id: Asset_ID) -> ([]u8, Result) {
    if !asset_valid(registry, id) {
        return nil, result_error(.Stale_Handle, "invalid asset handle")
    }
    record := &registry.records[id.index]
    if record.state != .Ready {
        return nil, result_error(.Invalid_State, "asset is not ready")
    }
    begin := int(record.payload_offset)
    end := begin+int(record.payload_size)
    if begin < 0 || end > registry.payload_count {
        return nil, result_error(.Invalid_State, "asset payload range is invalid")
    }
    return registry.payload[begin:end], result_ok()
}

asset_build_manifest :: proc(registry: ^Asset_Registry) -> Result {
    registry.manifest.count = 0
    registry.manifest.build_hash = 1469598103934665603
    registry.manifest.schema_version = 1
    for record in registry.records {
        if record.state != .Ready {
            continue
        }
        if registry.manifest.count >= len(registry.manifest.entries) {
            return result_error(.Capacity_Exceeded, "manifest capacity exceeded")
        }
        entry := Asset_Manifest_Entry{
            key = record.key,
            asset_type = record.asset_type,
            artifact_hash = record.artifact_hash,
            artifact_size = record.payload_size,
            schema_version = record.schema_version,
        }
        registry.manifest.entries[registry.manifest.count] = entry
        registry.manifest.count += 1
        registry.manifest.build_hash ^= entry.key.value
        registry.manifest.build_hash *= 1099511628211
        registry.manifest.build_hash ^= entry.artifact_hash
        registry.manifest.build_hash *= 1099511628211
    }
    return result_ok()
}

asset_collect_unused :: proc(registry: ^Asset_Registry, current_frame, unused_frames: u64) -> int {
    collected := 0
    for &record in registry.records {
        if record.state != .Ready || record.reference_count != 0 {
            continue
        }
        if current_frame < record.last_used_frame || current_frame-record.last_used_frame < unused_frames {
            continue
        }
        record.state = .Registered
        record.payload_offset = 0
        record.payload_size = 0
        if registry.loaded_count > 0 {
            registry.loaded_count -= 1
        }
        collected += 1
    }
    return collected
}

assets_self_check :: proc() {
    registry: Asset_Registry
    texture, result := asset_register(&registry, "assets/hero.texture", "cache/hero.texture.bin", "hero texture", .Texture, 1, 1)
    assert(result_is_ok(result))
    material, result := asset_register(&registry, "assets/hero.material", "cache/hero.material.bin", "hero material", .Material, 1, 1)
    assert(result_is_ok(result))
    texture_record := &registry.records[texture.index]
    assert(result_is_ok(asset_add_dependency(&registry, material, texture_record.key)))

    assert(result_is_ok(asset_queue(&registry, texture, 255)))
    request, found := asset_pop_request(&registry)
    assert(found && request.id == texture)
    assert(result_is_ok(asset_begin_load(&registry, request)))
    payload := []u8{1, 2, 3, 4}
    assert(result_is_ok(asset_complete_load(&registry, texture, payload, 11, 22)))

    assert(result_is_ok(asset_queue(&registry, material, 128)))
    request, found = asset_pop_request(&registry)
    assert(found)
    assert(result_is_ok(asset_begin_load(&registry, request)))
    assert(result_is_ok(asset_complete_load(&registry, material, []u8{9, 8}, 33, 44)))

    asset, result := asset_acquire(&registry, material, 10)
    assert(result_is_ok(result) && asset.state == .Ready)
    assert(result_is_ok(asset_release(&registry, material)))
    assert(result_is_ok(asset_build_manifest(&registry)))
    assert(registry.manifest.count == 2)
}
