const std = @import("std");
const Types = @import("botnet_types.zig");

const BotNode = Types.BotNode;
const C2Candidate = Types.C2Candidate;

pub fn detect_c2(
    allocator: std.mem.Allocator,
    nodes: []BotNode,
) ![]C2Candidate {

    var list = std.ArrayList(C2Candidate).init(allocator);

    for (nodes) |n| {

        if (n.activity_count > 10) {

            try list.append(.{
                .controller = n.ip,
                .bot_count = n.activity_count,
                .risk_score = n.avg_confidence,
            });
        }
    }

    return list.toOwnedSlice();
}