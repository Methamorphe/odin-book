package main

import "core:fmt"

Target_Frames_Per_Second :: 120
Nanoseconds_Per_Second   :: 1_000_000_000
Target_Frame_Time_NS     :: Nanoseconds_Per_Second / Target_Frames_Per_Second

main :: proc() {
    frame_index: u64 = 0
    running := true

    fmt.println("target FPS:", Target_Frames_Per_Second)
    fmt.println("frame budget (ns):", Target_Frame_Time_NS)
    fmt.println("first frame:", frame_index)
    fmt.println("running:", running)
}
