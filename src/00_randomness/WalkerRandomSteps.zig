// This matches the exercise in chapter 0, randomness; Exercise 6
// Use a custom probability distribution to vary the size of the
// random walker’s steps. The step size can be determined by influencing
// the range of values picked with a qualifying random value. Can you map the
// probability to a quadratic function by making the likelihood that a
// value is picked equal to the value squared?

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
        const xdir = random.intRangeAtMost(i8, -1, 1);
        const ydir = random.intRangeAtMost(i8, -1, 1);

        const maxStep = 10;
        const s = acceptReject(0, maxStep);

        self.x += xdir * s;
        self.y += ydir * s;
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.InitWindow(screenWidth, screenHeight, "Random Walk");
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

// Favours higher numbers, meaning your distribution would tend to the upper limit;
// Known as a monte carlo method;
fn acceptReject(low: u16, high: u16) i8 {
    while (true) {
        const r1 = random.intRangeAtMost(u16, low, high);
        // Probability maps to y = x^2
        const probability = r1 * r1;
        const r2 = random.intRangeAtMost(u16, low, high);

        if (r2 < probability) {
            return @intCast(r1);
        }
    }
}
