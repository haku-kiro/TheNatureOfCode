const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

const p = perlin.Perlin{};
const frequency = 0.01;

const Walker = struct {
    x: c_int,
    y: c_int,
    tx: f64 = 1000,
    ty: f64 = 10000,

    fn step(self: *Walker, width: f64, height: f64) void {
        const x_pos = p.noise(self.tx, 0, 0);
        const y_pos = p.noise(self.ty, 0, 0);
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

    rl.SetTargetFPS(10);

    // setup,
    var walker = Walker{ .x = screenWidth / 2, .y = screenHeight / 2 };
    // Setting the background color once (to have a "trail" effect);
    // rl.ClearBackground(rl.BLACK);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.DrawPixel(walker.x, walker.y, rl.WHITE);
        walker.step(screenWidth, screenHeight);
    }
}
