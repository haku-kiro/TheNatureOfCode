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

        self.x += xdir;
        self.y += ydir;
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.initWindow(screenWidth, screenHeight, "Random walk");
    defer rl.closeWindow();

    rl.setTargetFPS(30);

    // Setting the background color once (to have a "trail" effect);
    rl.clearBackground(rl.Color.white);

    // setup,
    var walker = Walker{ .x = screenWidth / 2, .y = screenHeight / 2 };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Prevent flashing by having this... But you don't have "trail" effect
        rl.clearBackground(rl.Color.white);

        rl.drawPixel(walker.x, walker.y, rl.Color.black);
        walker.step();
    }
}
