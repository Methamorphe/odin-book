package main

import "core:fmt"

Manifest_Entry :: struct {
    asset_id: u64,
    relative_path: string,
    size: u64,
    checksum: u64,
}

validate_manifest :: proc(entries: []Manifest_Entry) -> bool {
    for entry in entries {
        if entry.asset_id == 0 || len(entry.relative_path) == 0 || entry.size == 0 {
            return false
        }
    }
    return true
}

main :: proc() {
    entries := []Manifest_Entry{
        {asset_id = 1, relative_path = "data/scenes/main.asset", size = 2048, checksum = 0x1234},
        {asset_id = 2, relative_path = "data/textures/ui.asset", size = 4096, checksum = 0x5678},
    }
    fmt.println("manifest valid:", validate_manifest(entries))
}