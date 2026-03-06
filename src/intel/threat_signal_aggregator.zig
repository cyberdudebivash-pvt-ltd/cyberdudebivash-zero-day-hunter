const std = @import("std");
const Types = @import("threat_prediction_types.zig");

const ThreatSignal = Types.ThreatSignal;

pub fn aggregate(
    allocator: std.mem.Allocator,
    signals: []ThreatSignal,
) !std.StringHashMap(struct {
    count: u32,
    score: u32,
}) {

    var map = std.StringHashMap(struct {
        count: u32,
        score: u32,
    }).init(allocator);

    for (signals) |s| {

        if (map.get(s.category)) |entry| {
            var updated = entry;
            updated.count += 1;
            updated.score += s.confidence;

            try map.put(s.category, updated);
        } else {
            try map.put(s.category, .{
                .count = 1,
                .score = s.confidence,
            });
        }
    }

    return map;
}