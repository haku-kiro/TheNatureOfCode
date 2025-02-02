const std = @import("std");
const raylibBuild = @import("raylib");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add raylib library and link with your executable. This is the only raylib boilerplate.
    const raylib = try raylibBuild.addRaylib(b, target, optimize, .{
        // Optional - build & link raygui.
        .raygui = true,
    });

    const raylib_module = b.addModule("raylib", .{
        .root_source_file = b.path("src/raylib.zig"),
        .target = target,
        .optimize = optimize,
    });
    raylib_module.linkLibrary(raylib);

    const perlin_noise_module = b.addModule("perlin", .{
        .root_source_file = b.path("src/helpers/perlin.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "TheNatureOfCode",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("raylib", raylib_module);
    exe.root_module.addImport("perlin", perlin_noise_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    // Adding code to run various sub projects,
    inline for ([_]struct {
        name: []const u8,
        src: []const u8,
    }{
        // Add examples here as you make them;
        .{ .name = "RandomWalk", .src = "./src/00_randomness/RandomWalk.zig" },
        .{ .name = "UniformDistribution", .src = "./src/00_randomness/UniformDistribution.zig" },
        .{ .name = "RightWalker", .src = "./src/00_randomness/RightWalker.zig" },
        .{ .name = "NormalDistribution", .src = "./src/00_randomness/NormalDistribution.zig" },
        .{ .name = "AcceptRejectDistribution", .src = "./src/00_randomness/AcceptRejectDistribution.zig" },
        .{ .name = "WalkerRandomSteps", .src = "./src/00_randomness/WalkerRandomSteps.zig" },
        .{ .name = "PerlinGraphs", .src = "./src/00_randomness/PerlinGraphs.zig" },
        .{ .name = "PerlinWalker", .src = "./src/00_randomness/PerlinWalker.zig" },
        .{ .name = "TwoDPerlinNoise", .src = "./src/00_randomness/TwoDPerlinNoise.zig" },
    }) |execfg| {
        const ex_name = execfg.name;
        const ex_src = execfg.src;

        const ex_build_desc = try std.fmt.allocPrint(
            b.allocator,
            "build the {s} example",
            .{ex_name},
        );

        const ex_run_stepname = try std.fmt.allocPrint(
            b.allocator,
            "run-{s}",
            .{ex_name},
        );

        const ex_run_stepdesc = try std.fmt.allocPrint(
            b.allocator,
            "run the {s} example",
            .{ex_name},
        );

        const example_run_step = b.step(ex_run_stepname, ex_run_stepdesc);
        const example_step = b.step(ex_name, ex_build_desc);

        const example = b.addExecutable(.{
            .name = ex_name,
            .root_source_file = b.path(ex_src),
            .target = target,
            .optimize = optimize,
        });

        // If you use below, change example to 'var'.
        // Not sure about this for import raylib here, maybe?
        // example.root_module.addImport("module name", moduleName);

        // Imports that are being added to each example,
        example.root_module.addImport("raylib", raylib_module);
        example.root_module.addImport("perlin", perlin_noise_module);

        const example_run = b.addRunArtifact(example);
        example_run_step.dependOn(&example_run.step);

        const example_build_step = b.addInstallArtifact(example, .{});
        example_step.dependOn(&example_build_step.step);
    }
}
