const std = @import("std");

pub fn recordScan(host: []const u8) void {
    std.debug.print(
        "📊 Telemetry | scanned host: {s}\n",
        .{host},
    );
}

pub fn recordFinding(indicator: []const u8) void {
    std.debug.print(
        "🚨 Telemetry | finding detected: {s}\n",
        .{indicator},
    );
}

pub fn nodeHeartbeat(node_id: []const u8) void {
    std.debug.print(
        "💓 Node heartbeat received from {s}\n",
        .{node_id},
    );
}