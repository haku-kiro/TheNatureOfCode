const std = @import("std");
const rl = @import("raylib");
const perlin = @import("perlin");

const p = perlin.Perlin{};
const frequency = 0.05;
const octaves = 1;
const persistence = 0.7;

const width = 100;
const height = 100;
const scale = 0.1;

fn generateHeightmap() [width][height]f64 {
    var heightmap: [width][height]f64 = undefined;

    for (0..width) |x| {
        for (0..height) |y| {
            const nx = @as(f64, @floatFromInt(x)) * scale;
            const ny = @as(f64, @floatFromInt(y)) * scale;
            heightmap[x][y] = p.OctavePerlin(nx, ny, 0.0, octaves, persistence) * 30;
        }
    }

    return heightmap;
}

fn createTerrainMesh(allocator: std.mem.Allocator, heightmap: [width][height]f64) !rl.Mesh {
    const vertexCount = width * height;
    const triangleCount = (width - 1) * (height - 1) * 2;

    var vertices = try allocator.alloc(f32, vertexCount * 3);
    var indices = try allocator.alloc(u16, triangleCount * 3);

    // Generate vertices
    for (0..width) |x| {
        for (0..height) |y| {
            const idx = x * height + y;
            vertices[idx * 3 + 0] = @as(f32, @floatFromInt(x));
            vertices[idx * 3 + 1] = @as(f32, @floatCast(heightmap[x][y]));
            vertices[idx * 3 + 2] = @as(f32, @floatFromInt(y));
        }
    }

    // Generate indices
    var index: usize = 0;
    for (0..width - 1) |x| {
        for (0..height - 1) |y| {
            const idx = x * height + y;
            indices[index + 0] = @as(u16, @intCast(idx));
            indices[index + 1] = @as(u16, @intCast(idx + 1));
            indices[index + 2] = @as(u16, @intCast(idx + height));
            indices[index + 3] = @as(u16, @intCast(idx + 1));
            indices[index + 4] = @as(u16, @intCast(idx + height + 1));
            indices[index + 5] = @as(u16, @intCast(idx + height));
            index += 6;
        }
    }

    // Create mesh
    var mesh = rl.Mesh{
        .vertexCount = vertexCount,
        .triangleCount = triangleCount,
        .vertices = @ptrCast(vertices.ptr),
        .indices = @ptrCast(indices.ptr),
        .normals = null,
        .texcoords = null,
    };

    rl.UploadMesh(&mesh, false);
    return mesh;
}

fn drawTerrainGrid(heightmap: [width][height]f64) void {
    const lineColor = rl.BLACK;

    // Draw horizontal lines
    for (0..width) |x| {
        for (0..height - 1) |y| {
            const start = .{
                .x = @as(f32, @floatFromInt(x)),
                .y = @as(f32, @floatCast(heightmap[x][y])),
                .z = @as(f32, @floatFromInt(y)),
            };
            const end = .{
                .x = @as(f32, @floatFromInt(x)),
                .y = @as(f32, @floatCast(heightmap[x][y + 1])),
                .z = @as(f32, @floatFromInt(y + 1)),
            };
            rl.DrawLine3D(start, end, lineColor);
        }
    }

    // Draw vertical lines
    for (0..height) |y| {
        for (0..width - 1) |x| {
            const start = .{
                .x = @as(f32, @floatFromInt(x)),
                .y = @as(f32, @floatCast(heightmap[x][y])),
                .z = @as(f32, @floatFromInt(y)),
            };
            const end = .{
                .x = @as(f32, @floatFromInt(x + 1)),
                .y = @as(f32, @floatCast(heightmap[x + 1][y])),
                .z = @as(f32, @floatFromInt(y)),
            };
            rl.DrawLine3D(start, end, lineColor);
        }
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const screenWidth = 800;
    const screenHeight = 600;
    rl.InitWindow(screenWidth, screenHeight, "3D perlin noise");
    defer rl.CloseWindow();

    // Set up camera,
    var camera: rl.Camera3D = .{};
    camera.position = rl.Vector3{ .x = 100, .y = 100, .z = 100 };
    camera.target = rl.Vector3{ .x = width / 2, .y = 0, .z = height / 2 };
    camera.up = rl.Vector3{ .x = 0, .y = 2, .z = 0 };
    camera.fovy = 45;
    camera.projection = rl.CAMERA_PERSPECTIVE;

    rl.SetTargetFPS(30);

    const heightMap = generateHeightmap();
    const terrainMesh = try createTerrainMesh(allocator, heightMap);
    const terrainModel = rl.LoadModelFromMesh(terrainMesh);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.WHITE);
        // Rotates the camera and allows zooming with the scroll wheel.
        rl.UpdateCamera(&camera, rl.CAMERA_ORBITAL);

        rl.BeginMode3D(camera);

        rl.DrawModel(terrainModel, .{ .x = 0, .y = 0, .z = 0 }, 1.0, rl.GRAY);
        // To better see the heightmap
        drawTerrainGrid(heightMap);

        rl.EndMode3D();
        rl.DrawFPS(10, 10);
    }

    // rl.UnloadModel(terrainModel);
    // rl.UnloadMesh(terrainMesh);
}
