const std = @import("std");
const AndroidBuild = @import("src/android/android-build.zig");

pub const Psdk = @import("src/psdk.zig");
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

    // Create stub of builtin options.
    const android_builtin_options = std.Build.addOptions(b);
    android_builtin_options.addOption([:0]const u8, "package_name", "");
    android_mod.addImport("android_builtin", android_builtin_options.createModule());

    android_mod.linkSystemLibrary("log", .{});
}
