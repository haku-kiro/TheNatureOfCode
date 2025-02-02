const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

const p = perlin.Perlin{};
const frequency = 0.01;
const octaves = 8;
const persistence = 0.7;

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.InitWindow(screenWidth, screenHeight, "2D perlin noise");
    defer rl.CloseWindow();

    rl.SetTargetFPS(30);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.WHITE);

        var xoff: f64 = 0.0;
        for (0..screenWidth) |x| {
            var yoff: f64 = 0.0;
            for (0..screenHeight) |y| {
                const noise = p.OctavePerlin(xoff, yoff, 0, octaves, persistence);

                // TODO: Map colours or something here, instead of either black or white;

                if (noise > 0.5) {
                    const x_c: c_int = @intCast(x);
                    const y_c: c_int = @intCast(y);
                    rl.DrawPixel(x_c, y_c, rl.BLACK);
                }
                yoff += frequency;
            }
            xoff += frequency;
        }
    }
}
