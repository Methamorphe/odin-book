# Chapter 6 Exercises — Procedures

[← Chapter](../book/06-procedures.md) · [Solutions →](../solutions/06-procedures.md)

1. Write `subtract :: proc(a, b: int) -> int` and call it from `main`.
2. Write `min_max` returning two values without named results.
3. Write `safe_divide` returning `(value: f64, ok: bool)` and handle division by zero.
4. Define a `Transform :: proc(f32) -> f32` procedure type and an `apply_all` procedure that transforms a slice in place.
5. Add a default `precision` parameter to a formatting procedure.
6. Refactor a nested validation procedure into guard clauses.
7. Design distinct `User_ID` and `Order_ID` types, then write procedures that accept only the correct identifier.
8. Explain when `^const T` is preferable to passing `T` by value.
9. Create an overload set for adding two `i32` values and two `f32` values.
10. Challenge: build a tiny command dispatcher using procedure values and a map from command names to handlers.
