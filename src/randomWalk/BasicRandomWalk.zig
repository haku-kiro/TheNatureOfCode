const std = @import("std");
const rl = @import("raylib");

// Random number setup;
var prng = std.Random.DefaultPrng.init(42);
const random = prng.random();

const Walker = struct {
    x: c_int,
    y: c_int,
    fn step(self: *Walker) void {
        // Walking in either of 8 possible directions;
        const xdir = random.intRangeAtMost(i8, -1, 1);
        const ydir = random.intRangeAtMost(i8, -1, 1);

        self.x += xdir;
        self.y += ydir;
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.InitWindow(screenWidth, screenHeight, "Random walk");
    defer rl.CloseWindow();

    rl.SetTargetFPS(30);

    // Setting the background color once (to have a "trail" effect);
    rl.ClearBackground(rl.WHITE);

    // setup,
    var walker = Walker{ .x = screenWidth / 2, .y = screenHeight / 2 };

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.DrawPixel(walker.x, walker.y, rl.BLACK);
        walker.step();
    }
}
