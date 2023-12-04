const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "day1",
        .root_source_file = .{ .path = "day1.zig" },
    });

    b.installArtifact(exe);
}
