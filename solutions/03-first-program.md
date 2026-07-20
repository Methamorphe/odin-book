# Chapter 3 Solutions — Your First Odin Program

[← Exercises](../exercises/03-first-program.md) · [Back to Chapter 3](../book/03-first-program.md)

## Solution 3.1

```odin
package main

import "core:fmt"

main :: proc() {
    name := "Johann"
    primary_language := "TypeScript"

    fmt.println("Hello from", name)
    fmt.printf("My primary language is %s.\n", primary_language)
    fmt.println("I am learning Odin to build native, data-oriented software.")
}
```

## Solution 3.2

`greeting.odin`:

```odin
package main

build_greeting :: proc(name: string) -> string {
    return "Welcome, " + name
}
```

`main.odin`:

```odin
package main

import "core:fmt"

main :: proc() {
    fmt.println(build_greeting("Johann"))
}
```

Files in one directory package are compiled together and share package declarations, so they do not import one another.

## Solution 3.3

```odin
import output "core:fmt"
```

A good alias resolves a collision or improves a genuinely unclear imported name. Shortening an already clear name only to save keystrokes is usually poor justification.

## Solution 3.4

```odin
package main

import "core:fmt"
import "core:os"

main :: proc() {
    for argument, index in os.args {
        fmt.printf("[%d] %s\n", index, argument)
    }
}
```

Remember that the executable path normally occupies index zero.

## Solution 3.5

Exact diagnostic wording may vary by compiler version. A correct analysis identifies the first root cause rather than later cascading errors: unresolved name, inconsistent package declaration, package not imported, or declaration absent from the imported package.

## Solution 3.6

`greeting/greeting.odin`:

```odin
package greeting

build :: proc(name: string) -> string {
    return "Welcome, " + name
}
```

`main.odin`:

```odin
package main

import "core:fmt"
import "greeting"

main :: proc() {
    fmt.println(greeting.build("Johann"))
}
```

The exact relative import path depends on the project root and command location, but the important change is that the subdirectory is now a package boundary.

## Challenge solution

```odin
package main

import "core:fmt"
import "core:os"

report_arguments :: proc(arguments: []string) {
    user_arguments := arguments[1:]

    if len(user_arguments) == 0 {
        fmt.println("No user arguments were provided.")
        return
    }

    fmt.println("user argument count:", len(user_arguments))
    for argument, index in user_arguments {
        fmt.printf("%d. %s\n", index + 1, argument)
    }
}

main :: proc() {
    report_arguments(os.args)
}
```
