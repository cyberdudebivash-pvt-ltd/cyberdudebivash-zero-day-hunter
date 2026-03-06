const std = @import("std");

pub const Finding = struct {
    hunter: []const u8,
    issue: []const u8,
    confidence: u8,
    target: []const u8,
};

pub const CorrelatedSignal = struct {
    issue: []const u8,
    occurrences: u32,
    avg_confidence: u8,
};

pub fn correlate(
    allocator: std.mem.Allocator,
    findings: []Finding,
) ![]CorrelatedSignal {

    var map = std.StringHashMap(struct {
        count: u32,
        score: u32,
    }).init(allocator);

    for (findings) |f| {

        if (map.get(f.issue)) |entry| {
            var updated = entry;
            updated.count += 1;
            updated.score += f.confidence;
            try map.put(f.issue, updated);
        } else {
            try map.put(f.issue, .{
                .count = 1,
                .score = f.confidence,
            });
        }
    }

    var list = std.ArrayList(CorrelatedSignal).init(allocator);

    var it = map.iterator();
    while (it.next()) |entry| {

        const avg: u8 = @intCast(entry.value_ptr.score / entry.value_ptr.count);

        try list.append(.{
            .issue = entry.key_ptr.*,
            .occurrences = entry.value_ptr.count,
            .avg_confidence = avg,
        });
    }

    return list.toOwnedSlice();
}