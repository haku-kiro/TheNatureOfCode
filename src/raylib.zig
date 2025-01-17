// The raylib header includes are in a separate file to avoid repeated @cImport blocks.

const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");

    // @cInclude("raygui.h");
});

// You can write any custom bindings/helper functions here.
pub fn zVec3(x: f32, y: f32, z: f32) rl.Vector3 {
    return .{ .x = x, .y = y, .z = z };
}

pub usingnamespace rl;
