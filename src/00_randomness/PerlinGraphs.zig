const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

// Random number setup;
var prng = std.Random.DefaultPrng.init(42);
const random = prng.random();

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    rl.initWindow(screenWidth, screenHeight, "Perlin noise graph");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var time: f32 = 0.0;
    const octaves = 1;
    const frequency: f32 = 0.01;

    const n = perlin.Perlin{};

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        var xoff = time;
        for (0..screenWidth) |i| {
            const x_pos: c_int = @intCast(i);
            // Random noise line (uniform distribution)
            // Leaving commented out by default, if you want to plot uniform noise on a graph
            // uncomment the following:
            // const y_random = random.intRangeAtMost(c_int, 0, screenHeight);
            // const y_random_next = random.intRangeAtMost(c_int, 0, screenHeight);
            // rl.DrawLine(x_pos, y_random, x_pos + 1, y_random_next, rl.BLACK);

            // Perlin noise line
            const y_pos = generateNextYPerlin(n, xoff, screenHeight, octaves);
            // const y_next_pos = generateNextYPerlin(n, xoff + frequency, screenHeight, octaves);
            xoff += frequency;

            // rl.DrawLine(x_pos, y_pos, x_pos + 1, y_next_pos, rl.RED);
            rl.drawCircle(x_pos, y_pos, 5, rl.Color.red);
        }
        time += frequency;
    }
}

// Gets a perlin noise value, maps it between 0 and 1 and then applies it
// to the screen height
fn generateNextYPerlin(gen: perlin.Perlin, x: f32, screenHeight: usize, octaves: usize) c_int {
    // 1D perlin noise
    const noise = gen.OctavePerlin(x, x, x, octaves, 0.5);

    const screen_float: f32 = @floatFromInt(screenHeight);
    const y_pos: c_int = @intFromFloat(noise * screen_float);
    return y_pos;
}
