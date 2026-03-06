const std = @import("std");

pub const IntelRecord = struct {
    indicator: []const u8,
    source: []const u8,
};

pub fn store(record: IntelRecord) void {

    std.debug.print(
        "💾 Storing intelligence | Indicator: {s} | Source: {s}\n",
        .{ record.indicator, record.source },
    );
}

pub fn query(indicator: []const u8) void {

    std.debug.print(
        "🔍 Querying intel database for {s}\n",
        .{indicator},
    );
}