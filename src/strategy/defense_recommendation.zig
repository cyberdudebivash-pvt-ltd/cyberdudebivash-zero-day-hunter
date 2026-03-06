const std = @import("std");

pub fn recommend(
    strategy: []const u8,
) void {

    std.log.warn(
        "SOC Defense Recommendation: {s}",
        .{strategy},
    );
}