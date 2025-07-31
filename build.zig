
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const docelex = b.addSharedLibrary(.{
        .name = "docelex",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/tknzr.zig"),
        .version = .{
            .major = 0, .minor = 1, .patch = 0, .build = "debug",
        }
    });

    b.installArtifact(docelex);
}
