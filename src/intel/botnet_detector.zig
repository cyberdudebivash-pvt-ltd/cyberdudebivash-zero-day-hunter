const std = @import("std");
const Types = @import("botnet_types.zig");

const BotSignal = Types.BotSignal;
const BotNode = Types.BotNode;

pub fn detect_nodes(
    allocator: std.mem.Allocator,
    signals: []BotSignal,
) ![]BotNode {

    var map = std.StringHashMap(struct {
        count: u32,
        score: u32,
    }).init(allocator);

    for (signals) |s| {

        if (map.get(s.source_ip)) |entry| {
            var updated = entry;
            updated.count += 1;
            updated.score += s.confidence;

            try map.put(s.source_ip, updated);
        } else {
            try map.put(s.source_ip, .{
                .count = 1,
                .score = s.confidence,
            });
        }
    }

    var nodes = std.ArrayList(BotNode).init(allocator);

    var it = map.iterator();
    while (it.next()) |entry| {

        const avg = entry.value_ptr.score / entry.value_ptr.count;

        try nodes.append(.{
            .ip = entry.key_ptr.*,
            .activity_count = entry.value_ptr.count,
            .avg_confidence = @intCast(avg),
        });
    }

    return nodes.toOwnedSlice();
}