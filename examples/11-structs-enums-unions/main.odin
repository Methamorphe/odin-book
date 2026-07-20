package main

import "core:fmt"

Loading :: struct { progress: f32 }
Ready   :: struct { resource_id: u64 }
Failed  :: struct { message: string }
Asset_State :: union { Loading, Ready, Failed }

print_state :: proc(state: Asset_State) {
    switch value in state {
    case Loading: fmt.printf("loading %.0f%%\n", value.progress * 100)
    case Ready:   fmt.println("ready", value.resource_id)
    case Failed:  fmt.println("failed", value.message)
    }
}

main :: proc() {
    print_state(Loading{progress = 0.4})
    print_state(Ready{resource_id = 17})
}
