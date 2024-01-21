package main

import "core:runtime"
// import "core:fmt"
import "core:mem"
import "core:math/rand"
// import rl "vendor:raylib"
import rl "raylib"

foreign import "odin_env"

// @(default_calling_convention="c")
// foreign odin_env {
//     @(link_name="wasm_testing")
//     wasm_testing :: proc() ---
// }

camera: rl.Camera3D

ctx: runtime.Context

tempAllocatorData: [mem.Megabyte * 4]byte
tempAllocatorArena: mem.Arena

mainMemoryData: [mem.Megabyte * 16]byte
mainMemoryArena: mem.Arena

timer: f32
cubePos: [32]rl.Vector3
cubeColors: [32]rl.Color

@(export, link_name="_main")
_main :: proc "c" () {
    ctx = runtime.default_context()
    context = ctx

    mem.arena_init(&mainMemoryArena, mainMemoryData[:])
    mem.arena_init(&tempAllocatorArena, tempAllocatorData[:])

    ctx.allocator      = mem.arena_allocator(&mainMemoryArena)
    ctx.temp_allocator = mem.arena_allocator(&tempAllocatorArena)

    camera.position = {3, 3, 3}
    camera.target = {0,0,0}
    camera.up = {0, 1, 0}
    camera.fovy = 80
    camera.projection = .PERSPECTIVE

    rl.InitWindow(800, 600, "test")
    rl.SetTargetFPS(60)

    // wasm_testing()
}

@(export, link_name="step")
step :: proc "contextless" () {
    context = ctx
    update()
}

update :: proc() {
    free_all(context.temp_allocator)

    timer -= rl.GetFrameTime()
    if timer <= 0 {
        timer = 1

        for c in &cubePos {
            c.x = rand.float32_range(-10, 10)
            c.y = rand.float32_range(-10, 10)
            c.z = rand.float32_range(-10, 10)
        }

        for c in &cubeColors {
            c = rl.Color {
                u8(rand.uint32()),
                u8(rand.uint32()),
                u8(rand.uint32()),
                255,
            }

        }
    }

    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.UpdateCamera(&camera, .ORBITAL)

    rl.ClearBackground(rl.RAYWHITE)
    rl.BeginMode3D(camera)
    {
        for i in 0..<32 {
            rl.DrawCube(cubePos[i], 1, 1, 1, cubeColors[i])
        }
        rl.DrawGrid(10, 1)
    }
    rl.EndMode3D()
}