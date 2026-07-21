package main

import "core:fmt"

Test_Proc :: proc() -> bool
Test :: struct { name: string, run: Test_Proc }

pass :: proc() -> bool { return 2 + 2 == 4 }
fail_example :: proc() -> bool { return len("odin") == 4 }

run_all :: proc(tests: []Test) -> int {
    failed := 0
    for test in tests {
        ok := test.run()
        fmt.printf("%-24s %s\n", test.name, ok ? "PASS" : "FAIL")
        if !ok { failed += 1 }
    }
    return failed
}

main :: proc() {
    tests := [?]Test{{"arithmetic", pass}, {"string length", fail_example}}
    failed := run_all(tests[:])
    fmt.println("failed:", failed)
    assert(failed == 0)
}
