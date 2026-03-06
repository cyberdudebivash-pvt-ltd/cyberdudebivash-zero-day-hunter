const std = @import("std");

pub const ThreatRecord = struct {
    indicator: []const u8,
    category: []const u8,
};

var allocator = std.heap.page_allocator;
var storage = std.ArrayList(ThreatRecord).init(allocator);

pub fn store(indicator: []const u8, category: []const u8) !void {

    try storage.append(.{
        .indicator = indicator,
        .category = category,
    });

    std.debug.print(
        "💾 Threat stored: {s} ({s})\n",
        .{indicator, category},
    );
}

pub fn query() void {

    std.debug.print(
        "\n🗄 Global Threat Storage\n",
        .{},
    );

    for (storage.items) |r| {

        std.debug.print(
            "Indicator: {s} | Category: {s}\n",
            .{r.indicator, r.category},
        );
    }
}