const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

const p = perlin.Perlin{};
const frequency = 0.05;
const octaves = 6;
const persistence = 0.7;

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.InitWindow(screenWidth, screenHeight, "2D perlin noise");
    defer rl.CloseWindow();

    // TODO: instead of a really low framerate - render a texture once, and load that.
    rl.SetTargetFPS(1);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.WHITE);

        var xoff: f64 = 0.0;
        for (0..screenWidth) |x| {
            var yoff: f64 = 0.0;
            for (0..screenHeight) |y| {
                const noise = p.OctavePerlin(xoff, yoff, 0, octaves, persistence);

                const color = ColorFromNoise(noise);
                const x_c: c_int = @intCast(x);
                const y_c: c_int = @intCast(y);
                rl.DrawPixel(x_c, y_c, color);

                yoff += frequency;
            }
            xoff += frequency;
        }
    }
}

pub fn ColorFromNoise(noise: f64) rl.Color {
    const alpha_noise = @floor(perlin.map(noise, 0, 1, 0, 255));
    const mapped_alpha: u8 = @intFromFloat(alpha_noise);
    return rl.Color{ .r = 0, .g = 0, .b = 0, .a = mapped_alpha };
}
