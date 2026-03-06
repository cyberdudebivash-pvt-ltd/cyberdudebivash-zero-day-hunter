const std = @import("std");

pub fn registerNode(
    node_id: []const u8,
) void {

    std.log.info(
        "Hunter node registered: {s}",
        .{node_id},
    );
}