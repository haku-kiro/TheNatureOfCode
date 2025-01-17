const std = @import("std");
const rl = @import("raylib");

// Random number setup;
var prng = std.Random.DefaultPrng.init(42);
const random = prng.random();

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    const total = 20;
    var randomCounts = [_]u16{0} ** total;

    rl.InitWindow(screenWidth, screenHeight, "Random Number distribution");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        const index = random.intRangeAtMost(u8, 0, total - 1);
        randomCounts[index] += 1;

        const w = screenWidth / randomCounts.len;

        for (randomCounts, 0..) |num, idx| {
            const c_idx: c_int = @intCast(idx);
            const x_pos = c_idx * @as(c_int, w);
            const y_pos = screenHeight - @as(u16, randomCounts[idx]);
            rl.DrawRectangle(x_pos, y_pos, w - 1, num, rl.WHITE);
        }
    }
}
