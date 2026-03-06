const std = @import("std");

pub const ThreatEvent = struct {
    source_ip: []const u8,
    target_ip: []const u8,
    threat_type: []const u8,
    severity: u8,
};

var allocator = std.heap.page_allocator;
var stream = std.ArrayList(ThreatEvent).init(allocator);

pub fn publish(event: ThreatEvent) !void {

    try stream.append(event);

    std.debug.print(
        "📡 Live Threat Event: {s} → {s} | Type: {s} | Severity: {d}\n",
        .{
            event.source_ip,
            event.target_ip,
            event.threat_type,
            event.severity,
        },
    );
}

pub fn getStream() []ThreatEvent {

    return stream.items;
}

pub fn clear() void {

    stream.clearRetainingCapacity();
}