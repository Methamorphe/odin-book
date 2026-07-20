package main

import "core:fmt"
import "core:os"

report_arguments :: proc(arguments: []string) {
    if len(arguments) <= 1 {
        fmt.println("No user arguments were provided.")
        return
    }

    user_arguments := arguments[1:]
    fmt.println("user argument count:", len(user_arguments))

    for argument, index in user_arguments {
        fmt.printf("%d. %s\n", index + 1, argument)
    }
}

main :: proc() {
    report_arguments(os.args)
}
