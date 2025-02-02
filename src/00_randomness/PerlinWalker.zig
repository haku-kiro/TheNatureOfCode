const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

const p = perlin.Perlin{};
const frequency = 0.01;
const octaves = 8;

const Walker = struct {
    x: c_int,
    y: c_int,
    tx: f64 = 1000,
    ty: f64 = 10000,

    fn step(self: *Walker, width: f64, height: f64) void {
        const x_pos = p.OctavePerlin(self.tx, 0, 0, octaves, 0.5);
        const y_pos = p.OctavePerlin(self.ty, 0, 0, octaves, 0.5);
        self.tx += frequency;
        self.ty += frequency;

        const mapped_x = perlin.map(x_pos, 0, 1, 0, width);
        const mapped_y = perlin.map(y_pos, 0, 1, 0, height);

        self.x = @as(c_int, @intFromFloat(mapped_x));
        self.y = @as(c_int, @intFromFloat(mapped_y));
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.InitWindow(screenWidth, screenHeight, "Random walk");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    // setup,
    var walker = Walker{ .x = screenWidth / 2, .y = screenHeight / 2 };
    // Setting the background color once (to have a "trail" effect);
    // Note, on linux, this is fine - but mac/windows has a flashing effect
    // because of the double buffer rendering - change to black, then
    rl.ClearBackground(rl.WHITE);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.DrawCircle(walker.x, walker.y, 3, rl.PINK);
        walker.step(screenWidth, screenHeight);
    }
}
