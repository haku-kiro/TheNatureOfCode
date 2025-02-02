const std = @import("std");

pub const Perlin = struct {
    repeat: usize = 0,

    // Hash lookup table as defined by Ken Perlin.  This is a randomly
    // arranged array of all numbers from 0-255 inclusive.
    // zig fmt: off
    const permutation = [_]u8{ 
        151,160,137,91,90,15,
        131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
        190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
        88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
        77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
        102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
        135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
        5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
        223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
        129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
        251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
        49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
        138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
    };
    // zig fmt: on

    const p = blk: {
        var arr: [512]u8 = undefined;
        for (0..512) |i| {
            arr[i] = permutation[i % 256];
        }
        break :blk arr;
    };

    // Fade function, as defined by Ken Perlin. Eases coords
    // towards integral values - smoothing final input.
    // 6t^5 - 15t^4 + 10t^3
    fn fade(t: f64) f64 {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    // Linear interpolation: https://www.wikiwand.com/en/articles/Linear_interpolation
    fn lerp(a: f64, b: f64, x: f64) f64 {
        return a + x * (b - a);
    }

    fn inc(self: Perlin, num: usize) usize {
        const max_value = if (self.repeat > 0) self.repeat else 256;
        var n = num + 1;
        if (self.repeat > 0) n %= max_value;
        return n;
    }

    fn grad(hash: u8, x: f64, y: f64, z: f64) f64 {
        const h = hash & 15;
        const u = if (h < 8) x else y;
        const v = if (h < 4) y else if (h == 12 or h == 14) x else z;
        return (if ((h & 1) == 0) u else -u) + (if ((h & 2) == 0) v else -v);
    }

    pub fn perlin(self: Perlin, x_pos: f64, y_pos: f64, z_pos: f64) f64 {
        var x = x_pos;
        var y = y_pos;
        var z = z_pos;

        if (self.repeat > 0) {
            const repeat_f: f64 = @floatFromInt(self.repeat);
            x = @mod(x, repeat_f);
            y = @mod(y, repeat_f);
            z = @mod(z, repeat_f);
        }

        // Calculate the unit cube coords
        const xi = @as(usize, @intFromFloat(x)) & 255;
        const yi = @as(usize, @intFromFloat(y)) & 255;
        const zi = @as(usize, @intFromFloat(z)) & 255;

        // Get fractional parts
        const xf: f64 = x - @floor(x);
        const yf: f64 = y - @floor(y);
        const zf: f64 = z - @floor(z);

        const u = fade(xf);
        const v = fade(yf);
        const w = fade(zf);

        // Hash coordinates
        const aaa = p[p[p[xi] + yi] + zi];
        const aba = p[p[p[xi] + self.inc(yi)] + zi];
        const aab = p[p[p[xi] + yi] + self.inc(zi)];
        const abb = p[p[p[xi] + self.inc(yi)] + self.inc(zi)];
        const baa = p[p[p[self.inc(xi)] + yi] + zi];
        const bba = p[p[p[self.inc(xi)] + self.inc(yi)] + zi];
        const bab = p[p[p[self.inc(xi)] + yi] + self.inc(zi)];
        const bbb = p[p[p[self.inc(xi)] + self.inc(yi)] + self.inc(zi)];

        // Interpolate
        const x1 = lerp(grad(aaa, xf, yf, zf), grad(baa, xf - 1, yf, zf), u);
        const x2 = lerp(grad(aba, xf, yf - 1, zf), grad(bba, xf - 1, yf - 1, zf), u);
        const y1 = lerp(x1, x2, v);

        const x1_2 = lerp(grad(aab, xf, yf, zf - 1), grad(bab, xf - 1, yf, zf - 1), u);
        const x2_2 = lerp(grad(abb, xf, yf - 1, zf - 1), grad(bbb, xf - 1, yf - 1, zf - 1), u);
        const y2 = lerp(x1_2, x2_2, v);

        // Result is bound to 0 - 1, previous possible values where -1 - 1;
        return (lerp(y1, y2, w) + 1) / 2;
    }

    pub fn OctavePerlin(self: Perlin, x: f64, y: f64, z: f64, octaves: u32, persistence: f64) f64 {
        var total: f64 = 0;
        var frequency: f64 = 1;
        var amplitude: f64 = 1;
        var maxValue: f64 = 0;

        for (0..octaves) |_| {
            total += self.perlin(x * frequency, y * frequency, z * frequency) * amplitude;
            maxValue += amplitude;
            amplitude *= persistence;
            frequency *= 2;
        }

        return total / maxValue;
    }
};
