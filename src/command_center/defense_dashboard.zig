const std = @import("std");

pub fn showDefenseAction(
    infrastructure: []const u8,
) void {

    std.log.warn(
        "Autonomous Defense Action Executed: {s}",
        .{infrastructure},
    );
}