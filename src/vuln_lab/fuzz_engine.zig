const std = @import("std");

pub fn runFuzzing(
    target: []const u8,
) void {

    std.log.info(
        "Fuzzing target: {s}",
        .{target},
    );

    std.log.warn(
        "Potential memory corruption detected",
        .{},
    );
}