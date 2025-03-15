const std = @import("std");
const dvui = @import("dvui");
const RaylibBackend = dvui.backend;
comptime {
    std.debug.assert(@hasDecl(RaylibBackend, "RaylibBackend"));
}
// Raylib C API
const ray = RaylibBackend.c;

pub fn main() !void {
    var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_instance.allocator();

    defer _ = gpa_instance.deinit();
    defer ray.CloseWindow();

    ray.InitWindow(640, 480, "Hello Torizon");
    ray.ToggleFullscreen();

    var backend = RaylibBackend.init(gpa);
    defer backend.deinit();

    var win = try dvui.Window.init(
        @src(),
        gpa,
        backend.backend(),
        .{},
    );
    defer win.deinit();

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        try win.begin(std.time.nanoTimestamp());

        ray.ClearBackground(ray.RAYWHITE);
        try dvui.label(@src(), "Hello, Torizon!", .{}, .{
            .gravity_x = 0.5,
            .gravity_y = 0.5,
        });

        _ = try win.end(.{});
        ray.EndDrawing();
    }
}
