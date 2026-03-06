const std = @import("std");
const Types = @import("botnet_types.zig");

const BotNode = Types.BotNode;
const BotCluster = Types.BotCluster;

pub fn cluster_nodes(
    allocator: std.mem.Allocator,
    nodes: []BotNode,
) ![]BotCluster {

    var clusters = std.ArrayList(BotCluster).init(allocator);

    for (nodes) |n| {

        if (n.activity_count > 5) {

            try clusters.append(.{
                .cluster_id = n.ip,
                .node_count = 1,
                .activity_score = n.avg_confidence,
            });
        }
    }

    return clusters.toOwnedSlice();
}