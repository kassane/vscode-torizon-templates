const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Get a dependency using 'dvui' package
    const dep = b.dependency("dvui", .{
        .target = target,
        .optimize = optimize,
        // custom options (inherited from dvui - build.zig)
        // default is .all (all backends [dx11, sdl, web, raylib])
        .backend = .raylib,
        // if choose .sdl, get SDL2 (default) or SDL3
        // .sdl3 = true, // default is false
    });

    const binary = b.addExecutable(.{
        .name = "__change__",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Set backend to SDL
    // binary.root_module.addImport("dvui", dep.module("dvui_sdl"));
    // Set backend to Raylib
    binary.root_module.addImport("dvui", dep.module("dvui_raylib"));

    // copy binary from zig-cache to zig-out/bin [default]
    b.installArtifact(binary);

    // overwrite default output
    b.resolveInstallPrefix(b.fmt("zig-out/{s}/{s}", .{
        @tagName(binary.rootModuleTarget().cpu.arch),
        @tagName(optimize),
    }), .{});

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(binary);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc.`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", b.fmt("Run the {s} app", .{binary.name}));
    run_step.dependOn(&run_cmd.step);
}
