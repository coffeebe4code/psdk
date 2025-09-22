const std = @import("std");
const builtin = @import("builtin");
const psdk = @import("psdk");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const exe_name: []const u8 = "example";
    const root_target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const app_module = b.createModule(.{
        .target = root_target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    var exe = b.addExecutable(.{
        .name = exe_name,
        .root_module = app_module,
        .linkage = .static,
    });
    const sdl3_mod = b.dependency("sdl3", .{
        .target = root_target,
        .optimize = optimize,
        .c_sdl_preferred_linkage = .static,
    });
    exe.root_module.addImport("sdl3", sdl3_mod.module("sdl3"));

    b.installArtifact(exe);
}

//pub fn build(b: *std.Build) void {
//    const exe_name: []const u8 = "example";
//    const root_target = b.standardTargetOptions(.{});
//    const optimize = b.standardOptimizeOption(.{});
//    const android_targets = psdk.AndroidTargets(b, root_target);
//
//    var root_target_single = [_]std.Build.ResolvedTarget{root_target};
//    const targets: []std.Build.ResolvedTarget = if (android_targets.len == 0)
//        root_target_single[0..]
//    else
//        android_targets;
//
//    const android_apk: ?*psdk.AndroidApk = blk: {
//        if (android_targets.len == 0) break :blk null;
//
//        const android_sdk = psdk.AndroidSdk.create(b, .{});
//        const apk = android_sdk.createApk(.{
//            .api_level = .android15,
//            .build_tools_version = "35.0.1",
//            .ndk_version = "29.0.13113456",
//        });
//        const key_store_file = android_sdk.createKeyStore(.example);
//        apk.setKeyStore(key_store_file);
//        apk.setAndroidManifest(b.path("android/AndroidManifest.xml"));
//        apk.addResourceDirectory(b.path("android/res"));
//        apk.addAssetsDirectory(b.path("android/assets"));
//        break :blk apk;
//    };
//
//    for (targets) |target| {
//        const app_module = b.createModule(.{
//            .target = target,
//            .optimize = optimize,
//            .root_source_file = b.path("src/main.zig"),
//        });
//
//        var exe: *std.Build.Step.Compile = if (target.result.abi.isAndroid()) b.addLibrary(.{
//            .name = exe_name,
//            .root_module = app_module,
//            .linkage = .dynamic,
//        }) else b.addExecutable(.{
//            .name = exe_name,
//            .root_module = app_module,
//            .linkage = .static,
//        });
//        const sdl3_mod = b.dependency("sdl3", .{
//            .target = target,
//            .optimize = optimize,
//            .c_sdl_preferred_linkage = .static,
//        });
//        exe.root_module.addImport("sdl3", sdl3_mod.module("sdl3"));
//
//        if (target.result.abi.isAndroid()) {
//            const apk: *psdk.AndroidApk = android_apk orelse @panic("Android APK should be initialized");
//            const android_dep = b.dependency("psdk", .{
//                .optimize = optimize,
//                .target = target,
//            });
//            exe.root_module.addImport("android", android_dep.module("android"));
//            exe.root_module.linkSystemLibrary("android", .{});
//
//            apk.addArtifact(exe);
//        } else {
//            b.installArtifact(exe);
//
//            // If only 1 target, add "run" step
//            if (targets.len == 1) {
//                const run_step = b.step("run", "Run the application");
//                const run_cmd = b.addRunArtifact(exe);
//                run_step.dependOn(&run_cmd.step);
//            }
//        }
//    }
//    if (android_apk) |apk| {
//        const installed_apk = apk.addInstallApk();
//        b.getInstallStep().dependOn(&installed_apk.step);
//
//        const android_sdk = apk.sdk;
//        const run_step = b.step("run", "Install and run the application on an Android device");
//        const adb_install = android_sdk.addAdbInstall(installed_apk.source);
//        const adb_start = android_sdk.addAdbStart("com.zig.minimal/android.app.NativeActivity");
//        adb_start.step.dependOn(&adb_install.step);
//        run_step.dependOn(&adb_start.step);
//    }
//}
