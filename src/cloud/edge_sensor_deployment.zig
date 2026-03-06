const std = @import("std");

pub const EdgeSensor = struct {
    id: []const u8,
    location: []const u8,
};

var allocator = std.heap.page_allocator;
var sensors = std.ArrayList(EdgeSensor).init(allocator);

pub fn deploy(id: []const u8, location: []const u8) !void {

    try sensors.append(.{
        .id = id,
        .location = location,
    });

    std.debug.print(
        "📡 Edge sensor deployed: {s} ({s})\n",
        .{id, location},
    );
}

pub fn list() void {

    std.debug.print(
        "\n🌍 Edge Sensor Network\n",
        .{},
    );

    for (sensors.items) |s| {

        std.debug.print(
            "Sensor: {s} | Location: {s}\n",
            .{s.id, s.location},
        );
    }
}