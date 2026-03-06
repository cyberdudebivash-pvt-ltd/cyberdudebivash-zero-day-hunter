const std = @import("std");
const Types = @import("threat_prediction_types.zig");

const ThreatTrend = Types.ThreatTrend;

pub fn analyze(
    allocator: std.mem.Allocator,
    map: std.StringHashMap(struct {
        count: u32,
        score: u32,
    }),
) ![]ThreatTrend {

    var trends = std.ArrayList(ThreatTrend).init(allocator);

    var it = map.iterator();

    while (it.next()) |entry| {

        const avg = entry.value_ptr.score / entry.value_ptr.count;

        try trends.append(.{
            .category = entry.key_ptr.*,
            .signal_count = entry.value_ptr.count,
            .avg_confidence = @intCast(avg),
        });
    }

    return trends.toOwnedSlice();
}