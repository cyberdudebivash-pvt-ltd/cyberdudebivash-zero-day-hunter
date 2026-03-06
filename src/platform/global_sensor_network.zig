const std = @import("std");

pub const Sensor = struct {
    id: []const u8,
    location: []const u8,
    status: []const u8,
};

var allocator = std.heap.page_allocator;
var sensors = std.ArrayList(Sensor).init(allocator);

pub fn registerSensor(id: []const u8, location: []const u8) !void {

    try sensors.append(.{
        .id = id,
        .location = location,
        .status = "online",
    });

    std.debug.print(
        "📡 Sensor registered: {s} ({s})\n",
        .{ id, location },
    );
}

pub fn ingestTelemetry(sensor_id: []const u8, event: []const u8) void {

    std.debug.print(
        "📥 Telemetry from {s}: {s}\n",
        .{ sensor_id, event },
    );
}

pub fn listSensors() void {

    std.debug.print(
        "\n🌐 Global Sensor Network\n",
        .{},
    );

    for (sensors.items) |s| {

        std.debug.print(
            "Sensor {s} | Location: {s} | Status: {s}\n",
            .{ s.id, s.location, s.status },
        );
    }
}