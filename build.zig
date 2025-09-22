const std = @import("std");
const AndroidBuild = @import("src/android/android-build.zig");

pub const AndroidSdk = @import("src/android/sdk.zig");
pub const AndroidApk = @import("src/android/apk.zig");
pub const AndroidApiLevel = AndroidBuild.ApiLevel;
pub const AndroidTargets = AndroidBuild.standardTargets;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const android_mod = b.addModule("android", .{
        .root_source_file = b.path("src/android.zig"),
        .target = target,
        .optimize = optimize,
    });

    const android_bind_mod = b.addModule("android-bind", .{
        .root_source_file = b.path("src/android-bind.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = android_bind_mod;

    const ios_mod = b.addModule("ios", .{
        .root_source_file = b.path("src/ios.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = ios_mod;

    const ios_bind_mod = b.addModule("ios-bind", .{
        .root_source_file = b.path("src/ios-bind.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = ios_bind_mod;

    // Create stub of builtin options.
    const android_builtin_options = std.Build.addOptions(b);
    android_builtin_options.addOption([:0]const u8, "package_name", "");
    android_mod.addImport("android_builtin", android_builtin_options.createModule());

    android_mod.linkSystemLibrary("log", .{});
}
