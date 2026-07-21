package main

import "core:fmt"

API_VERSION :: u32(1)
Plugin_API :: struct {
    version: u32,
    name: string,
    update: proc(state: ^State, dt: f32),
}
State :: struct { ticks: u64, accumulated: f32 }
Host :: struct { active: Plugin_API, previous: Plugin_API, state: State }

update_v1 :: proc(state: ^State, dt: f32) {
    state.ticks += 1
    state.accumulated += dt
}

validate :: proc(api: Plugin_API) -> bool {
    return api.version == API_VERSION && api.update != nil && len(api.name) > 0
}

reload :: proc(host: ^Host, candidate: Plugin_API) -> bool {
    if !validate(candidate) { return false }
    host.previous = host.active
    host.active = candidate
    return true
}

main :: proc() {
    host := Host{active = Plugin_API{API_VERSION, "game-v1", update_v1}}
    assert(validate(host.active))
    host.active.update(&host.state, 1.0/60.0)
    incompatible := Plugin_API{2, "bad", update_v1}
    assert(!reload(&host, incompatible))
    assert(host.active.name == "game-v1")
    fmt.println("plugin:", host.active.name, "ticks:", host.state.ticks)
}
