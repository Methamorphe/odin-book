package main

U64_Set :: struct {
    keys: [4096]u64,
    states: [4096]u8,
    count: int,
}

U64_Map_Entry :: struct {
    key: u64,
    value: u64,
    state: u8,
}

U64_Map :: struct {
    entries: [4096]U64_Map_Entry,
    count: int,
}

Event_Queue :: struct {
    events: [MAX_EVENTS]Platform_Event,
    read_index: int,
    write_index: int,
    count: int,
    dropped: u64,
}

Index_Queue :: struct {
    values: [4096]u32,
    read_index: int,
    write_index: int,
    count: int,
}

String_Table_Entry :: struct {
    hash: u64,
    offset: u32,
    length: u16,
    occupied: bool,
}

String_Table :: struct {
    bytes: [128*1024]u8,
    byte_count: int,
    entries: [2048]String_Table_Entry,
    count: int,
}

Dense_Index_Set :: struct {
    dense: [MAX_ENTITIES]u32,
    sparse: [MAX_ENTITIES]u32,
    present: [MAX_ENTITIES]bool,
    count: int,
}

hash_mix_u64 :: proc(value: u64) -> u64 {
    x := value
    x ^= x >> 30
    x *= 0xbf58476d1ce4e5b9
    x ^= x >> 27
    x *= 0x94d049bb133111eb
    x ^= x >> 31
    return x
}

u64_set_insert :: proc(set: ^U64_Set, key: u64) -> (bool, Result) {
    if set.count >= len(set.keys)*3/4 {
        return false, result_error(.Capacity_Exceeded, "set load factor exceeded")
    }
    start := int(hash_mix_u64(key)%u64(len(set.keys)))
    first_tombstone := -1
    for probe in 0..<len(set.keys) {
        index := (start+probe)%len(set.keys)
        switch set.states[index] {
        case 0:
            target := first_tombstone >= 0 ? first_tombstone : index
            set.keys[target] = key
            set.states[target] = 1
            set.count += 1
            return true, result_ok()
        case 1:
            if set.keys[index] == key {
                return false, result_ok()
            }
        case 2:
            if first_tombstone < 0 {
                first_tombstone = index
            }
        }
    }
    return false, result_error(.Capacity_Exceeded, "set probe exhausted")
}

u64_set_contains :: proc(set: ^U64_Set, key: u64) -> bool {
    start := int(hash_mix_u64(key)%u64(len(set.keys)))
    for probe in 0..<len(set.keys) {
        index := (start+probe)%len(set.keys)
        if set.states[index] == 0 {
            return false
        }
        if set.states[index] == 1 && set.keys[index] == key {
            return true
        }
    }
    return false
}

u64_set_remove :: proc(set: ^U64_Set, key: u64) -> bool {
    start := int(hash_mix_u64(key)%u64(len(set.keys)))
    for probe in 0..<len(set.keys) {
        index := (start+probe)%len(set.keys)
        if set.states[index] == 0 {
            return false
        }
        if set.states[index] == 1 && set.keys[index] == key {
            set.states[index] = 2
            set.count -= 1
            return true
        }
    }
    return false
}

u64_map_put :: proc(map: ^U64_Map, key, value: u64) -> (bool, Result) {
    if map.count >= len(map.entries)*3/4 {
        return false, result_error(.Capacity_Exceeded, "map load factor exceeded")
    }
    start := int(hash_mix_u64(key)%u64(len(map.entries)))
    first_tombstone := -1
    for probe in 0..<len(map.entries) {
        index := (start+probe)%len(map.entries)
        entry := &map.entries[index]
        switch entry.state {
        case 0:
            target := first_tombstone >= 0 ? first_tombstone : index
            map.entries[target] = U64_Map_Entry{key, value, 1}
            map.count += 1
            return true, result_ok()
        case 1:
            if entry.key == key {
                entry.value = value
                return false, result_ok()
            }
        case 2:
            if first_tombstone < 0 {
                first_tombstone = index
            }
        }
    }
    return false, result_error(.Capacity_Exceeded, "map probe exhausted")
}

u64_map_get :: proc(map: ^U64_Map, key: u64) -> (u64, bool) {
    start := int(hash_mix_u64(key)%u64(len(map.entries)))
    for probe in 0..<len(map.entries) {
        index := (start+probe)%len(map.entries)
        entry := &map.entries[index]
        if entry.state == 0 {
            return 0, false
        }
        if entry.state == 1 && entry.key == key {
            return entry.value, true
        }
    }
    return 0, false
}

u64_map_remove :: proc(map: ^U64_Map, key: u64) -> bool {
    start := int(hash_mix_u64(key)%u64(len(map.entries)))
    for probe in 0..<len(map.entries) {
        index := (start+probe)%len(map.entries)
        entry := &map.entries[index]
        if entry.state == 0 {
            return false
        }
        if entry.state == 1 && entry.key == key {
            entry.state = 2
            map.count -= 1
            return true
        }
    }
    return false
}

event_queue_push :: proc(queue: ^Event_Queue, event: Platform_Event) -> bool {
    if queue.count == len(queue.events) {
        queue.dropped += 1
        return false
    }
    queue.events[queue.write_index] = event
    queue.write_index = (queue.write_index+1)%len(queue.events)
    queue.count += 1
    return true
}

event_queue_pop :: proc(queue: ^Event_Queue) -> (Platform_Event, bool) {
    if queue.count == 0 {
        return {}, false
    }
    event := queue.events[queue.read_index]
    queue.read_index = (queue.read_index+1)%len(queue.events)
    queue.count -= 1
    return event, true
}

event_queue_clear :: proc(queue: ^Event_Queue) {
    queue.read_index = 0
    queue.write_index = 0
    queue.count = 0
}

index_queue_push :: proc(queue: ^Index_Queue, value: u32) -> bool {
    if queue.count == len(queue.values) {
        return false
    }
    queue.values[queue.write_index] = value
    queue.write_index = (queue.write_index+1)%len(queue.values)
    queue.count += 1
    return true
}

index_queue_pop :: proc(queue: ^Index_Queue) -> (u32, bool) {
    if queue.count == 0 {
        return 0, false
    }
    value := queue.values[queue.read_index]
    queue.read_index = (queue.read_index+1)%len(queue.values)
    queue.count -= 1
    return value, true
}

string_table_intern :: proc(table: ^String_Table, text: string) -> (u32, Result) {
    hash := hash_string(text)
    start := int(hash_mix_u64(hash)%u64(len(table.entries)))
    for probe in 0..<len(table.entries) {
        index := (start+probe)%len(table.entries)
        entry := &table.entries[index]
        if !entry.occupied {
            if table.byte_count+len(text) > len(table.bytes) {
                return 0, result_error(.Capacity_Exceeded, "string table byte storage exhausted")
            }
            if len(text) > max(u16) {
                return 0, result_error(.Invalid_Argument, "interned string is too long")
            }
            entry.hash = hash
            entry.offset = u32(table.byte_count)
            entry.length = u16(len(text))
            entry.occupied = true
            if len(text) > 0 {
                copy(table.bytes[table.byte_count:table.byte_count+len(text)], transmute([]u8)text)
            }
            table.byte_count += len(text)
            table.count += 1
            return u32(index), result_ok()
        }
        if entry.hash == hash && int(entry.length) == len(text) {
            existing := string(table.bytes[entry.offset:entry.offset+u32(entry.length)])
            if existing == text {
                return u32(index), result_ok()
            }
        }
    }
    return 0, result_error(.Capacity_Exceeded, "string table entry storage exhausted")
}

string_table_resolve :: proc(table: ^String_Table, id: u32) -> (string, bool) {
    if id >= u32(len(table.entries)) {
        return "", false
    }
    entry := &table.entries[id]
    if !entry.occupied {
        return "", false
    }
    begin := int(entry.offset)
    end := begin+int(entry.length)
    return string(table.bytes[begin:end]), true
}

dense_set_contains :: proc(set: ^Dense_Index_Set, value: u32) -> bool {
    return value < MAX_ENTITIES && set.present[value]
}

dense_set_insert :: proc(set: ^Dense_Index_Set, value: u32) -> (bool, Result) {
    if value >= MAX_ENTITIES {
        return false, result_error(.Invalid_Argument, "dense set value out of range")
    }
    if set.present[value] {
        return false, result_ok()
    }
    if set.count >= len(set.dense) {
        return false, result_error(.Capacity_Exceeded, "dense set exhausted")
    }
    dense_index := set.count
    set.dense[dense_index] = value
    set.sparse[value] = u32(dense_index)
    set.present[value] = true
    set.count += 1
    return true, result_ok()
}

dense_set_remove :: proc(set: ^Dense_Index_Set, value: u32) -> bool {
    if value >= MAX_ENTITIES || !set.present[value] {
        return false
    }
    dense_index := int(set.sparse[value])
    last_index := set.count-1
    moved := set.dense[last_index]
    set.dense[dense_index] = moved
    set.sparse[moved] = u32(dense_index)
    set.count -= 1
    set.present[value] = false
    set.sparse[value] = 0
    return true
}

dense_set_validate :: proc(set: ^Dense_Index_Set) -> bool {
    if set.count < 0 || set.count > len(set.dense) {
        return false
    }
    for dense_index in 0..<set.count {
        value := set.dense[dense_index]
        if value >= MAX_ENTITIES || !set.present[value] || set.sparse[value] != u32(dense_index) {
            return false
        }
    }
    return true
}

containers_self_check :: proc() {
    set: U64_Set
    inserted, result := u64_set_insert(&set, 42)
    assert(inserted && result_is_ok(result))
    inserted, result = u64_set_insert(&set, 42)
    assert(!inserted && result_is_ok(result))
    assert(u64_set_contains(&set, 42))
    assert(u64_set_remove(&set, 42))
    assert(!u64_set_contains(&set, 42))

    map: U64_Map
    _, result = u64_map_put(&map, 7, 99)
    assert(result_is_ok(result))
    value, found := u64_map_get(&map, 7)
    assert(found && value == 99)

    table: String_Table
    first, result := string_table_intern(&table, "player")
    assert(result_is_ok(result))
    second, result := string_table_intern(&table, "player")
    assert(result_is_ok(result) && first == second)
    text, found := string_table_resolve(&table, first)
    assert(found && text == "player")

    dense: Dense_Index_Set
    _, result = dense_set_insert(&dense, 8)
    assert(result_is_ok(result))
    _, result = dense_set_insert(&dense, 3)
    assert(result_is_ok(result))
    assert(dense_set_remove(&dense, 8))
    assert(dense_set_validate(&dense))
}
