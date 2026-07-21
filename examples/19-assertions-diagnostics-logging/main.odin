package main

import "core:fmt"

Severity :: enum {
    Info,
    Warning,
    Error,
}

Diagnostic :: struct {
    severity: Severity,
    code:     string,
    message:  string,
    path:     string,
}

report :: proc(diagnostic: Diagnostic) {
    fmt.printf(
        "severity=%v code=%s path=%q message=%q\n",
        diagnostic.severity,
        diagnostic.code,
        diagnostic.path,
        diagnostic.message,
    )
}

main :: proc() {
    diagnostic := Diagnostic {
        severity = .Error,
        code = "CFG-004",
        message = "unsupported configuration version",
        path = "settings.json",
    }

    report(diagnostic)
}
