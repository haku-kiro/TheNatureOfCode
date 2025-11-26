const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ---------------------------------------------------------
    // 1. Fetch Raylib using the new dependency system
    // ---------------------------------------------------------
    // This replaces: const raylibBuild = @import("raylib");
    // and: raylibBuild.addRaylib(...)

    // Note: "raylib-zig" must match the name in your build.zig.zon dependencies
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    // Get the compiled C library (artifact) and the Zig bindings (module)
    const raylib_artifact = raylib_dep.artifact("raylib");
    const raylib_module = raylib_dep.module("raylib");

    // ---------------------------------------------------------
    // 2. Define your shared helper modules
    // ---------------------------------------------------------
    const perlin_noise_module = b.createModule(.{
        .root_source_file = b.path("src/helpers/perlin.zig"),
        .target = target,
        .optimize = optimize,
    });

    // ---------------------------------------------------------
    // 3. Main Executable
    // ---------------------------------------------------------
    const exe = b.addExecutable(.{
        .name = "TheNatureOfCode",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Link the raylib C library
    exe.linkLibrary(raylib_artifact);
    // Import the raylib Zig bindings
    exe.root_module.addImport("raylib", raylib_module);
    // Import your helper module
    exe.root_module.addImport("perlin", perlin_noise_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // ---------------------------------------------------------
    // 4. Unit Tests
    // ---------------------------------------------------------
    const exe_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Tests also need to link raylib if they import it
    exe_unit_tests.linkLibrary(raylib_artifact);
    exe_unit_tests.root_module.addImport("raylib", raylib_module);
    exe_unit_tests.root_module.addImport("perlin", perlin_noise_module);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    // ---------------------------------------------------------
    // 5. Examples Loop
    // ---------------------------------------------------------
    inline for ([_]struct {
        name: []const u8,
        src: []const u8,
    }{
        .{ .name = "RandomWalk", .src = "./src/00_randomness/RandomWalk.zig" },
        .{ .name = "UniformDistribution", .src = "./src/00_randomness/UniformDistribution.zig" },
        .{ .name = "RightWalker", .src = "./src/00_randomness/RightWalker.zig" },
        .{ .name = "NormalDistribution", .src = "./src/00_randomness/NormalDistribution.zig" },
        .{ .name = "AcceptRejectDistribution", .src = "./src/00_randomness/AcceptRejectDistribution.zig" },
        .{ .name = "WalkerRandomSteps", .src = "./src/00_randomness/WalkerRandomSteps.zig" },
        .{ .name = "PerlinGraphs", .src = "./src/00_randomness/PerlinGraphs.zig" },
        .{ .name = "PerlinWalker", .src = "./src/00_randomness/PerlinWalker.zig" },
        .{ .name = "TwoDPerlinNoise", .src = "./src/00_randomness/TwoDPerlinNoise.zig" },
        .{ .name = "ThreeDPerlin", .src = "./src/00_randomness/ThreeDPerlin.zig" },
        .{ .name = "BasicBouncingBall", .src = "./src/01_vectors/BasicBouncingBall.zig" },
    }) |execfg| {
        const ex_name = execfg.name;
        const ex_src = execfg.src;

        const example = b.addExecutable(.{
            .name = ex_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(ex_src),
                .target = target,
                .optimize = optimize,
            }),
        });

        // Link/Import for each example
        example.linkLibrary(raylib_artifact);
        example.root_module.addImport("raylib", raylib_module);
        example.root_module.addImport("perlin", perlin_noise_module);

        const example_run = b.addRunArtifact(example);
        const example_install = b.addInstallArtifact(example, .{});

        // Steps
        const ex_run_stepname = try std.fmt.allocPrint(b.allocator, "run-{s}", .{ex_name});
        const ex_run_stepdesc = try std.fmt.allocPrint(b.allocator, "run the {s} example", .{ex_name});
        const example_run_step = b.step(ex_run_stepname, ex_run_stepdesc);
        example_run_step.dependOn(&example_run.step);

        const ex_build_desc = try std.fmt.allocPrint(b.allocator, "build the {s} example", .{ex_name});
        const example_step = b.step(ex_name, ex_build_desc);
        example_step.dependOn(&example_install.step);
    }
}
