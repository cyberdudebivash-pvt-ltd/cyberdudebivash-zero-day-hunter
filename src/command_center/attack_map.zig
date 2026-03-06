const std = @import("std");

pub fn renderAttackMap(
    infrastructure: []const u8,
) void {

    std.log.info(
        "Attack Map: malicious infrastructure detected {s}",
        .{infrastructure},
    );
}