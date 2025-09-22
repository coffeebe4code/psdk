const std = @import("std");
const builtin = @import("builtin");
const android = @import("android");
const sdl3 = @import("sdl3");

const log = std.log;
const assert = std.debug.assert;
const fps = 60;
const screen_width = 640;
const screen_height = 480;

/// custom standard options for Android
pub const std_options: std.Options = if (builtin.abi.isAndroid())
    .{
        .logFn = android.logFn,
    }
else
    .{};

/// custom panic handler for Android
pub const panic = if (builtin.abi.isAndroid())
    android.panic
else
    std.debug.FullPanic(std.debug.defaultPanic);

comptime {
    if (builtin.abi.isAndroid()) {
        @export(&SDL_main, .{ .name = "SDL_main", .linkage = .strong });
    }
}

/// This needs to be exported for Android builds
fn SDL_main() callconv(.c) void {
    if (comptime builtin.abi.isAndroid()) {
        _ = std.start.callMain();
    } else {
        @compileError("SDL_main should not be called outside of Android builds");
    }
}

pub fn main() !void {
    defer sdl3.shutdown();

    // Initialize SDL with subsystems you need here.
    const init_flags = sdl3.InitFlags{ .video = true, .audio = true };
    try sdl3.init(init_flags);
    defer sdl3.quit(init_flags);

    // Initial window setup.
    const window = try sdl3.video.Window.init("Hello SDL3", screen_width, screen_height, .{});
    defer window.deinit();

    // Useful for limiting the FPS and getting the delta time.
    var fps_capper = sdl3.extras.FramerateCapper(f32){ .mode = .{ .limited = fps } };

    var quit = false;
    while (!quit) {

        // Delay to limit the FPS, returned delta time not needed.
        const dt = fps_capper.delay();
        _ = dt;

        // Update logic.
        const surface = try window.getSurface();
        try surface.fillRect(null, surface.mapRgb(128, 30, 255));
        try window.updateSurface();

        // Event logic.
        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => quit = true,
                .terminating => quit = true,
                else => {},
            };
    }
}

const FrameLog = enum {
    none,
    one_frame_passed,
    logged_one_frame,
};
