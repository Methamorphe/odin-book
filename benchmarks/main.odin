package main

import "core:fmt"
import "core:time"

ITEM_COUNT :: 262_144
ROUNDS     :: 64
STRIDE     :: 257

Particle_AoS :: struct {
    x, y:   f32,
    vx, vy: f32,
    mass:   f32,
    flags:  u32,
}

Particle_SoA :: struct {
    x, y:   []f32,
    vx, vy: []f32,
}

Handle :: struct {
    index:      u32,
    generation: u32,
}

Handle_Table :: struct {
    values:      []u64,
    generations: []u32,
}

print_result :: proc(name: string, elapsed: time.Duration, checksum: f64) {
    fmt.printf("%-38s %10.3f ms  checksum=%0.3f\n", name, time.duration_milliseconds(elapsed), checksum)
}

benchmark_aos_soa :: proc() {
    aos := make([]Particle_AoS, ITEM_COUNT)
    defer delete(aos)

    soa := Particle_SoA{
        x  = make([]f32, ITEM_COUNT),
        y  = make([]f32, ITEM_COUNT),
        vx = make([]f32, ITEM_COUNT),
        vy = make([]f32, ITEM_COUNT),
    }
    defer delete(soa.x)
    defer delete(soa.y)
    defer delete(soa.vx)
    defer delete(soa.vy)

    for i in 0..<ITEM_COUNT {
        value := f32(i % 1024) * 0.01
        aos[i] = Particle_AoS{x = value, y = value, vx = 1.25, vy = -0.5, mass = 1, flags = 1}
        soa.x[i] = value
        soa.y[i] = value
        soa.vx[i] = 1.25
        soa.vy[i] = -0.5
    }

    start_aos := time.tick_now()
    for _ in 0..<ROUNDS {
        for i in 0..<ITEM_COUNT {
            aos[i].x += aos[i].vx * 0.016
            aos[i].y += aos[i].vy * 0.016
        }
    }
    elapsed_aos := time.tick_since(start_aos)

    start_soa := time.tick_now()
    for _ in 0..<ROUNDS {
        for i in 0..<ITEM_COUNT {
            soa.x[i] += soa.vx[i] * 0.016
            soa.y[i] += soa.vy[i] * 0.016
        }
    }
    elapsed_soa := time.tick_since(start_soa)

    print_result("particle update: array of structs", elapsed_aos, f64(aos[ITEM_COUNT-1].x + aos[ITEM_COUNT-1].y))
    print_result("particle update: structure of arrays", elapsed_soa, f64(soa.x[ITEM_COUNT-1] + soa.y[ITEM_COUNT-1]))
}

benchmark_traversal :: proc() {
    values := make([]u64, ITEM_COUNT)
    defer delete(values)
    for i in 0..<ITEM_COUNT {
        values[i] = u64(i + 1)
    }

    sequential_sum: u64
    start_sequential := time.tick_now()
    for _ in 0..<ROUNDS {
        for value in values {
            sequential_sum += value
        }
    }
    elapsed_sequential := time.tick_since(start_sequential)

    strided_sum: u64
    start_strided := time.tick_now()
    for _ in 0..<ROUNDS {
        index := 0
        for _ in 0..<ITEM_COUNT {
            strided_sum += values[index]
            index = (index + STRIDE) % ITEM_COUNT
        }
    }
    elapsed_strided := time.tick_since(start_strided)

    print_result("buffer sum: contiguous", elapsed_sequential, f64(sequential_sum))
    print_result("buffer sum: strided", elapsed_strided, f64(strided_sum))
}

resolve :: proc(table: ^Handle_Table, handle: Handle) -> (u64, bool) {
    index := int(handle.index)
    if index < 0 || index >= len(table.values) {
        return 0, false
    }
    if table.generations[index] != handle.generation {
        return 0, false
    }
    return table.values[index], true
}

benchmark_handles :: proc() {
    table := Handle_Table{
        values      = make([]u64, ITEM_COUNT),
        generations = make([]u32, ITEM_COUNT),
    }
    defer delete(table.values)
    defer delete(table.generations)

    handles := make([]Handle, ITEM_COUNT)
    defer delete(handles)

    for i in 0..<ITEM_COUNT {
        table.values[i] = u64(i + 1)
        table.generations[i] = 7
        handles[i] = Handle{index = u32(i), generation = 7}
    }

    direct_sum: u64
    start_direct := time.tick_now()
    for _ in 0..<ROUNDS {
        for i in 0..<ITEM_COUNT {
            direct_sum += table.values[i]
        }
    }
    elapsed_direct := time.tick_since(start_direct)

    validated_sum: u64
    start_validated := time.tick_now()
    for _ in 0..<ROUNDS {
        for handle in handles {
            value, found := resolve(&table, handle)
            if found {
                validated_sum += value
            }
        }
    }
    elapsed_validated := time.tick_since(start_validated)

    print_result("lookup: direct index", elapsed_direct, f64(direct_sum))
    print_result("lookup: generational handle", elapsed_validated, f64(validated_sum))
}

benchmark_temporary_storage :: proc() {
    BUFFER_SIZE :: 16_384
    TEMP_ROUNDS :: 2_048

    reused := make([]u32, BUFFER_SIZE)
    defer delete(reused)

    reused_sum: u64
    start_reused := time.tick_now()
    for round in 0..<TEMP_ROUNDS {
        for i in 0..<BUFFER_SIZE {
            reused[i] = u32(i + round)
        }
        reused_sum += u64(reused[BUFFER_SIZE-1])
    }
    elapsed_reused := time.tick_since(start_reused)

    allocated_sum: u64
    start_allocated := time.tick_now()
    for round in 0..<TEMP_ROUNDS {
        temporary := make([]u32, BUFFER_SIZE)
        for i in 0..<BUFFER_SIZE {
            temporary[i] = u32(i + round)
        }
        allocated_sum += u64(temporary[BUFFER_SIZE-1])
        delete(temporary)
    }
    elapsed_allocated := time.tick_since(start_allocated)

    print_result("temporary storage: reused", elapsed_reused, f64(reused_sum))
    print_result("temporary storage: allocate/free", elapsed_allocated, f64(allocated_sum))
}

main :: proc() {
    fmt.println("The Odin Programming Book — benchmark suite")
    fmt.printf("items=%d rounds=%d optimized build recommended\n\n", ITEM_COUNT, ROUNDS)

    benchmark_aos_soa()
    benchmark_traversal()
    benchmark_handles()
    benchmark_temporary_storage()
}
