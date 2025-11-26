const std = @import("std");
const rl = @import("raylib");

var prng = std.Random.DefaultPrng.init(42);
const random = prng.random();

const Walker = struct {
    x: c_int,
    y: c_int,
    fn step(self: *Walker) void {
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

    const canvas = try rl.loadRenderTexture(screenWidth, screenHeight);
    defer rl.unloadRenderTexture(canvas);

    // Clear the canvas once at the start
    rl.beginTextureMode(canvas);
    rl.clearBackground(rl.Color.white);
    rl.endTextureMode();

    var walker = Walker{ .x = screenWidth / 2, .y = screenHeight / 2 };

    while (!rl.windowShouldClose()) {
        // Draw to the persistent canvas
        rl.beginTextureMode(canvas);
        rl.drawPixel(walker.x, walker.y, rl.Color.black);
        rl.endTextureMode();

        walker.step();

        // Draw the canvas to the screen
        rl.beginDrawing();
        rl.drawTexture(canvas.texture, 0, 0, rl.Color.white);
        rl.endDrawing();
    }
}
