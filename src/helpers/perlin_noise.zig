// Rewrite of the following: https://github.com/2G-Afroz/perlin-noise/blob/main/src/perlin_noise.cpp
// Note, doesn't use precomputed gradients - as such it works for any number of grid coordinates.

const std = @import("std");

pub fn interpolate(a: f32, b: f32, t: f32) f32 {
    // Cubic interpolation, for a smooth appearance?
    return a + t * t * (3.0 - 2.0 * t) * (b - a);
}

// Returns a single random point, for 1D Perlin Noise
pub fn getRandom(x: f32) f32 {
    const w = 8 * @sizeOf(u32);
    const s = w / 2;
    var a: u32 = @intFromFloat(x);

    // For wrapping arithmitic, you need to be explicit in zig;
    a *%= 3284157443;
    // Using truncate because zig requires explicit truncation for shift counts,
    // as 's' is calculated at runtime
    a ^= (a << @truncate(s)) | (a >> @truncate(w - s));
    a *%= 1911520717;
    a ^= (a << @truncate(s)) | (a >> @truncate(w - s));
    a *%= 2048419325;

    const max_u32 = @as(f32, @floatFromInt(~@as(u32, 0)));
    return @as(f32, @floatFromInt(a)) / max_u32 - 0.5;
}

pub fn map(value: f32, fromLow: f32, fromHigh: f32, toLow: f32, toHigh: f32) f32 {
    const v = @min(@max(value, fromLow), fromHigh);
    // Map a value to the target range
    return toLow + (toHigh - toLow) * ((v - fromLow) / (fromHigh - fromLow));
}

pub fn perlinNoise(x: f32, octaves: usize) f32 {
    var frequency: f32 = 1.0;
    var amplitude: f32 = 1.0;
    var total: f32 = 0;
    var x_modifier = x;

    for (0..octaves) |_| {
        x_modifier *= frequency;
        const x0: f32 = std.math.floor(x_modifier);
        const x1: f32 = x0 + 1.0;

        const gX0 = map(getRandom(x0), -0.5, 0.5, -amplitude / 2, amplitude / 2);
        const gX1 = map(getRandom(x1), -0.5, 0.5, -amplitude / 2, amplitude / 2);

        const t = x_modifier - x0;

        total += interpolate(gX0, gX1, t);

        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return total;
}

const vector2 = struct { x: f32, y: f32 };

pub fn getRandom2d(x: f32, y: f32) vector2 {
    const x_int: usize = @intCast(x);
    const y_int: usize = @intCast(y);
    const w: usize = 8 * @sizeOf(u32);
    const s: usize = w / 2; // rotation width
    var a = x_int;
    var b = y_int;

    a *= 3284157443;
    b ^= a << s | a >> (w - s);
    b *= 1911520717;
    a ^= b << s | b >> (w - s);
    a *= 2048419325;

    const random: f32 = @as(f32, @floatFromInt(a)) * (3.14159265 / @as(f32, @floatFromInt(~@as(u32, 0 >> 1))));
    return vector2{
        .x = @cos(random), // Return a value between -1 and 1
        .y = @sin(random), // Return a value between -1 and 1
    };
}

pub fn dotGridPoint(ix: f32, iy: f32, x: f32, y: f32) f32 {
    // Obtain random gradient vectors at the specified grid point (ix, iy)
    const rand = getRandom2d(ix, iy);

    // Calculate the distance from the grid point to the given point (x, y)
    const dx = x - ix;
    const dy = y - iy;

    // Compute the dot product between the distance vectors and the gradient vectors
    return (dx * rand.x + dy * rand.y);
}

pub fn perlinNoise2d(x: f32, y: f32, octaves: usize) f32 {
    var frequency: f32 = 1.0;
    var amplitude: f32 = 1.0;
    var total: f32 = 0.0;

    for (0..octaves) |_| {
        // Scale the coords based on the current frequency
        x *= frequency;
        y *= frequency;

        // Calculate the integer grid coords of the surrounding points
        const x0 = @as(f32, @floor(x));
        const x1 = x0 + 1;
        const y0 = @as(f32, @floor(y));
        const y1 = y0 + 1;

        // Calculate the fractional parts of the coords
        const xt = x - x0;
        const yt = y - y0;

        // Compute noise values at the grid points and interpolate between them
        var n0 = dotGridPoint(x0, y0, x, y);
        var n1 = dotGridPoint(x1, y0, x, y);
        const xn = interpolate(n0, n1, xt);

        n0 = dotGridPoint(x0, y1, x, y);
        n1 = dotGridPoint(x1, y1, x, y);
        const yn = interpolate(n0, n1, xt);

        // Interpolate along the y-axis and map the result to a sepcific range
        const interpolatedNoise = interpolate(xn, yn, yt);
        const mappedNoise = map(interpolatedNoise, -0.7, 0.7, -amplitude, amplitude);

        // Accumulate the noise value with proper scaling
        total += mappedNoise;

        // Update frequency and amplitude for the next octave
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return total;
}
