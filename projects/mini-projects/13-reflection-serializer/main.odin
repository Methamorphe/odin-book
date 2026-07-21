package main

import "core:fmt"
import "core:reflect"

Config :: struct { width: i32, height: i32, title: string, fullscreen: bool }

print_schema :: proc($T: typeid) {
    info := type_info_of(T)
    s, ok := info.variant.(reflect.Type_Info_Struct)
    if !ok { return }
    for name, i in s.names { fmt.println(name, s.types[i]) }
}

main :: proc() {
    _ = Config{1280, 720, "Threadline", false}
    print_schema(Config)
}
