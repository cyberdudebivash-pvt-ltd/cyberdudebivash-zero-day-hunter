const std = @import("std");

pub fn submitIntel(
    node_id: []const u8,
    finding: []const u8,
) void {

    std.log.warn(
        "Intel submitted from node {s}: {s}",
        .{node_id, finding},
    );
}