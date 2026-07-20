package main

import "core:fmt"

Resource :: struct { name: string }

acquire :: proc(name: string) -> (Resource, bool) {
    fmt.println("acquire", name)
    return Resource{name = name}, true
}

release :: proc(resource: Resource) {
    fmt.println("release", resource.name)
}

main :: proc() {
    first, ok := acquire("first")
    if !ok { return }
    defer release(first)

    second, ok := acquire("second")
    if !ok { return }
    defer release(second)

    fmt.println("using resources")
}
