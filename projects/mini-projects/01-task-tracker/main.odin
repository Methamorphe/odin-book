package main

import "core:fmt"

Status :: enum { Todo, Doing, Done }
Task :: struct { id: u32, title: string, status: Status }
Store :: struct { tasks: [64]Task, count: int, next_id: u32 }

add :: proc(s: ^Store, title: string) -> (u32, bool) {
    if s.count >= len(s.tasks) || len(title) == 0 { return 0, false }
    id := s.next_id
    s.next_id += 1
    s.tasks[s.count] = Task{id = id, title = title, status = .Todo}
    s.count += 1
    return id, true
}

set_status :: proc(s: ^Store, id: u32, status: Status) -> bool {
    for i in 0..<s.count {
        if s.tasks[i].id == id { s.tasks[i].status = status; return true }
    }
    return false
}

remove :: proc(s: ^Store, id: u32) -> bool {
    for i in 0..<s.count {
        if s.tasks[i].id == id {
            copy(s.tasks[i:s.count-1], s.tasks[i+1:s.count])
            s.count -= 1
            return true
        }
    }
    return false
}

main :: proc() {
    store := Store{next_id = 1}
    first, ok := add(&store, "write parser")
    assert(ok)
    _, ok = add(&store, "add tests")
    assert(ok)
    assert(set_status(&store, first, .Doing))
    for task in store.tasks[:store.count] { fmt.println(task.id, task.status, task.title) }
    assert(remove(&store, first))
    fmt.println("remaining:", store.count)
}
