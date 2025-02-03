const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

const p = perlin.Perlin{};
const frequency = 0.05;
const octaves = 6;
const persistence = 0.7;

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 600;
    rl.InitWindow(screenWidth, screenHeight, "3D perlin noise");
    defer rl.CloseWindow();

    // Set up camera,
    var camera: rl.Camera3D = .{};
    camera.position = rl.Vector3{ .x = 0, .y = 7, .z = 7 };
    camera.target = rl.Vector3{ .x = 0, .y = 0, .z = 0 };
    camera.up = rl.Vector3{ .x = 0, .y = 1, .z = 0 };
    camera.fovy = 45;
    camera.projection = rl.CAMERA_PERSPECTIVE;

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.WHITE);

        rl.BeginMode3D(camera);
        rl.DrawGrid(10, 1);
        rl.DrawCube(.{ .x = 0, .y = 0, .z = 0 }, 1, 1, 1, rl.RED);
        rl.EndMode3D();
        rl.DrawFPS(10, 10);
    }
}
