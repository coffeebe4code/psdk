const std = @import("std");
const builtin = @import("builtin");
const psdk = @import("psdk");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const exe_name: []const u8 = "example";
    const root_target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const android_targets = psdk.AndroidTargets(b, root_target);

    const android_apk: ?*psdk.AndroidApk = blk: {
        if (android_targets.len == 0) break :blk null;

        const android_sdk = psdk.AndroidSdk.create(b, .{});
        const apk = android_sdk.createApk(.{
            .api_level = .android15,
            .build_tools_version = "35.0.1",
            .ndk_version = "29.0.13113456",
        });
        const key_store_file = android_sdk.createKeyStore(.example);
        apk.setKeyStore(key_store_file);
        apk.setAndroidManifest(b.path("android/AndroidManifest.xml"));
        apk.addResourceDirectory(b.path("android/res"));
        apk.addAssetsDirectory(b.path("android/assets"));
        break :blk apk;
    };

    const app_module = b.createModule(.{
        .target = root_target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    var exe: *std.Build.Step.Compile = if (root_target.result.abi.isAndroid()) b.addLibrary(.{
        .name = exe_name,
        .root_module = app_module,
        .linkage = .dynamic,
    }) else b.addExecutable(.{
        .name = exe_name,
        .root_module = app_module,
    });
    const sdl3_mod = if (root_target.result.os.tag == .windows) b.dependency("sdl3", .{
        .target = root_target,
        .optimize = optimize,
        .c_sdl_preferred_linkage = .static,
    }) else b.dependency("sdl3", .{
        .target = root_target,
        .optimize = optimize,
        .c_sdl_preferred_linkage = .dynamic,
    });

    exe.root_module.addImport("sdl3", sdl3_mod.module("sdl3"));

    if (root_target.result.abi.isAndroid()) {
        const apk: *psdk.AndroidApk = android_apk orelse @panic("Android APK should be initialized");
        const android_dep = b.dependency("psdk", .{
            .optimize = optimize,
            .target = root_target,
        });
        exe.root_module.addImport("android", android_dep.module("android"));
        exe.root_module.linkSystemLibrary("android", .{});

        apk.addArtifact(exe);
    }
    b.installArtifact(exe);
}
