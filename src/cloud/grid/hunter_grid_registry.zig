const std = @import("std");
const Types = @import("hunter_node_types.zig");

const HunterNode = Types.HunterNode;

pub fn register(
    allocator: std.mem.Allocator,
) ![]HunterNode {

    var nodes = std.ArrayList(HunterNode).init(allocator);

    try nodes.append(.{
        .node_id = "node-eu-01",
        .region = "EU",
    });

    try nodes.append(.{
        .node_id = "node-us-01",
        .region = "US",
    });

    try nodes.append(.{
        .node_id = "node-apac-01",
        .region = "APAC",
    });

    return nodes.toOwnedSlice();
}