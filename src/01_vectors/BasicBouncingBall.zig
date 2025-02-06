const std = @import("std");
const rl = @import("raylib");

var x: f32 = 100;
var y: f32 = 100;
var xspeed: f32 = 4.5;
var yspeed: f32 = 4;
const ball_radius = 50;

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "Basic Bouncing Ball, without vectors");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        x += xspeed;
        y += yspeed;

        if (x + ball_radius > screenWidth or x < ball_radius) xspeed *= -1;
        if (y + ball_radius > screenHeight or y < ball_radius) yspeed *= -1;

        const x_pos: c_int = @intFromFloat(x);
        const y_pos: c_int = @intFromFloat(y);

        rl.DrawCircle(x_pos, y_pos, ball_radius, rl.WHITE);
    }
}
