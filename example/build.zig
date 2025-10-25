const std = @import("std");
const builtin = @import("builtin");
const Psdk = @import("psdk").Psdk;

const exe_name: []const u8 = "example";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    var p = Psdk.init(b, exe_name, .all_allowed_targets);

    try p.createAndroidEnv(.example, .{
        .api_level = .android15,
        .build_tools_version = "36.1.0",
        .ndk_version = "29.0.14033849",
    });

    const app_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    //const exe = p.handleBuild(app_module, target, optimize);
    const sdl3_mod = b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
        .preferred_linkage = .static,
    });
    app_module.addImport("sdl3", sdl3_mod.module("sdl3"));

    //const sdl3_mod = if (target.result.os.tag == .windows) b.dependency("sdl3", .{
    //    .target = target,
    //    .optimize = optimize,
    //    .preferred_linkage = .static,
    //}) else b.dependency("sdl3", .{
    //    .target = target,
    //    .optimize = optimize,
    //    .preferred_linkage = .static,
    //});

    const exe: *std.Build.Step.Compile = if (target.result.abi.isAndroid()) b.addLibrary(.{
        .name = exe_name,
        .root_module = app_module,
        .linkage = .dynamic,
        .use_llvm = true,
        .use_lld = true,
    }) else b.addExecutable(.{
        .name = exe_name,
        .root_module = app_module,
    });

    b.installArtifact(exe);
}
