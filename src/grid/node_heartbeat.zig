const std = @import("std");

pub fn heartbeat(
    node_id: []const u8,
) void {

    std.log.info(
        "Node heartbeat received: {s}",
        .{node_id},
    );
}