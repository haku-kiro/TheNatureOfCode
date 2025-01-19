const std = @import("std");
const rl = @import("raylib");

// Random number setup;
var prng = std.Random.DefaultPrng.init(42);
const random = prng.random();

const Walker = struct {
    x: c_int,
    y: c_int,
    fn step(self: *Walker) void {
        // Walking in either of 8 possible directions,
        // or stay in the same position;
        const dir = random.intRangeAtMost(u8, 0, 9);

        switch (dir) {
            // More likely to go right.
            0...3 => self.x += 1,
            4...5 => self.x -= 1,
            6...7 => self.y += 1,
            8...9 => self.y -= 1,
            else => unreachable,
        }
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.InitWindow(screenWidth, screenHeight, "Random walk");
    defer rl.CloseWindow();

    rl.SetTargetFPS(30);
    rl.ClearBackground(rl.WHITE);

    var walker = Walker{ .x = screenWidth / 2, .y = screenHeight / 2 };

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.DrawPixel(walker.x, walker.y, rl.BLACK);
        walker.step();
    }
}
