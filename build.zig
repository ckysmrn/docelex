
const std = @import("std");

fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const docelex = b.addSharedLibrary(.{
        .name = "docelex",
        .target = target,
        .optimize = optimize,
        .version = .{
            .major = 0, .minor = 1, .patch = 0, .build = "debug",
        }
    });

    b.installArtifact(docelex);
}
