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

    const exe = p.handleBuild(app_module, target, optimize);
    b.installArtifact(exe);
}
