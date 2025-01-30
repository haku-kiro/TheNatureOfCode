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

    rl.InitWindow(screenWidth, screenHeight, "Uniform Random Number distribution");
    defer rl.CloseWindow();

    rl.SetTargetFPS(80);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        const index = acceptReject(0, total - 1);
        if (randomCounts[index] < screenHeight) randomCounts[index] += 1;

        const w = screenWidth / randomCounts.len;

        for (randomCounts, 0..) |num, idx| {
            const x_pos: c_int = @intCast(idx * w);
            const y_pos: c_int = @intCast(screenHeight - randomCounts[idx]);
            rl.DrawRectangle(x_pos, y_pos, w - 1, num, rl.WHITE);
        }
    }
}

// Favours higher numbers, meaning your distribution would tend to the upper limit;
// Known as a monte carlo method;
fn acceptReject(low: u8, high: u8) u8 {
    while (true) {
        const r1 = random.intRangeAtMost(u8, low, high);
        const r2 = random.intRangeAtMost(u8, low, high);

        if (r2 < r1) {
            return r1;
        }
    }
}
