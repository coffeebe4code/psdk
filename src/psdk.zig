const Psdk = @This();
const AndroidApk = @import("android/apk.zig");
const AndroidSdk = @import("android/sdk.zig");
const AndroidNdk = @import("android/ndk.zig");

const std = @import("std");

pub const EnabledOptions = struct {
    android: bool,
    linux: bool,

    pub const all_allowed_targets: EnabledOptions = .{
        .android = true,
        .linux = true,
    };
};

exe_name: []const u8,
b: *std.Build,
options: EnabledOptions,
android_apk: *AndroidApk,
android_sdk: *AndroidSdk,
android_ndk: *AndroidNdk,

pub fn init(b: *std.Build, exe_name: []const u8, opts: EnabledOptions) Psdk {
    return .{
        .b = b,
        .exe_name = exe_name,
        .options = opts,
        .android_apk = undefined,
        .android_sdk = undefined,
        .android_ndk = undefined,
    };
}

pub fn createAndroidEnv(self: *Psdk, key: AndroidSdk.CreateKey, opts: AndroidApk.Options) !void {
    self.android_sdk = AndroidSdk.create(self.b, .{});
    self.android_apk = self.android_sdk.createApk(opts);

    const key_store_file = self.android_sdk.createKeyStore(key);
    self.android_apk.setKeyStore(key_store_file);
    self.android_apk.setAndroidManifest(self.b.path("android/AndroidManifest.xml"));
    self.android_apk.addResourceDirectory(self.b.path("android/res"));
    self.android_apk.addAssetsDirectory(self.b.path("android/assets"));
}

pub fn handleBuild(self: *Psdk, mod: *std.Build.Module, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step.Compile {
    const sdl3_mod = if (target.result.os.tag == .windows) self.b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
        .preferred_linkage = .static,
    }) else self.b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
        .preferred_linkage = .dynamic,
    });

    var exe: *std.Build.Step.Compile = if (target.result.abi.isAndroid()) self.b.addLibrary(.{
        .name = self.exe_name,
        .root_module = mod,
        .linkage = .dynamic,
        .use_llvm = true,
        .use_lld = true,
    }) else self.b.addExecutable(.{
        .name = self.exe_name,
        .root_module = mod,
    });

    mod.addImport("sdl3", sdl3_mod.module("sdl3"));

    if (target.result.abi.isAndroid()) {
        const android_dep = self.b.dependency("psdk", .{
            .optimize = optimize,
            .target = target,
        });
        exe.root_module.addImport("android", android_dep.module("android"));
        exe.root_module.linkSystemLibrary("android", .{});

        self.android_apk.addArtifact(exe);
    }
    return exe;
}
