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

    var showMessageBox: bool = false;

    rl.InitWindow(screenWidth, screenHeight, "Normal distribution random number generation");
    defer rl.CloseWindow();

    rl.SetTargetFPS(80);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        const button = rl.GuiButton(rl.Rectangle{ .x = 24, .y = 24, .width = 120, .height = 30 }, "#191#Show Message");
        if (button == 1) showMessageBox = true;

        if (showMessageBox) {
            const result = rl.GuiMessageBox(rl.Rectangle{ .x = 85, .y = 70, .width = 250, .height = 100 }, "#191#Message Box", "Hi! This is a message!", "Nice;Cool");
            if (result >= 0) showMessageBox = false;
        }

        const index = normalDistributionIntsBetween(random, 1, total - 1);
        if (randomCounts[index] < screenHeight) randomCounts[index] += 1;

        const w = screenWidth / randomCounts.len;

        for (randomCounts, 0..) |num, idx| {
            const x_pos: c_int = @intCast(idx * w);
            const y_pos: c_int = @intCast(screenHeight - randomCounts[idx]);
            rl.DrawRectangle(x_pos, y_pos, w - 1, num, rl.WHITE);
        }
    }
}

fn normalDistributionIntsBetween(r: std.Random, low: u8, high: u8) u8 {
    const f_high: f32 = @floatFromInt(high);
    const f_low: f32 = @floatFromInt(low);
    // Just "hardcoding" the midpoint as the average.
    const avg: f32 = f_high / 2.0;
    const stdDeviation: f32 = 2.5;

    var num = random.floatNorm(f32) * stdDeviation + avg;
    // We're doing this to "anchor" our value between the lower and upper bound.
    while (num > f_high or num < f_low) {
        num = r.floatNorm(f32) * stdDeviation + avg;
    }

    return @intFromFloat(num);
}
