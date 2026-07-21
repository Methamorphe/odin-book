package main

import "core:fmt"

Raw_Handle :: distinct rawptr

Resource :: struct {
    handle: Raw_Handle,
}

resource_is_valid :: proc(resource: Resource) -> bool {
    return rawptr(resource.handle) != nil
}

resource_destroy :: proc(resource: ^Resource) {
    if !resource_is_valid(resource^) do return

    // A real wrapper would call the foreign destroy procedure here.
    resource.handle = Raw_Handle(nil)
}

main :: proc() {
    resource := Resource{}
    defer resource_destroy(&resource)

    fmt.println("resource valid:", resource_is_valid(resource))
}