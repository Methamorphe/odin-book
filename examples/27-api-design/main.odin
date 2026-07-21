package main

import "core:fmt"

Resource_Handle :: distinct u32

Resource_Error :: enum {
    None,
    Invalid_Description,
    Capacity_Exceeded,
}

Resource_Desc :: struct {
    name: string,
    size: int,
}

resource_create :: proc(desc: Resource_Desc) -> (Resource_Handle, Resource_Error) {
    if len(desc.name) == 0 || desc.size <= 0 {
        return 0, .Invalid_Description
    }

    if desc.size > 1_024 {
        return 0, .Capacity_Exceeded
    }

    return Resource_Handle(1), .None
}

main :: proc() {
    handle, err := resource_create({name = "example", size = 64})
    if err != .None {
        fmt.println("creation failed:", err)
        return
    }

    fmt.println("resource handle:", u32(handle))
}