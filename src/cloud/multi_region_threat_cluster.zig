const std = @import("std");

pub const RegionCluster = struct {
    region: []const u8,
    nodes: u32,
};

var allocator = std.heap.page_allocator;
var clusters = std.ArrayList(RegionCluster).init(allocator);

pub fn register(region: []const u8, nodes: u32) !void {

    try clusters.append(.{
        .region = region,
        .nodes = nodes,
    });

    std.debug.print(
        "☁ Threat cluster registered: {s} | Nodes: {d}\n",
        .{region, nodes},
    );
}

pub fn list() void {

    std.debug.print(
        "\n🌐 Multi-Region Threat Clusters\n",
        .{},
    );

    for (clusters.items) |c| {

        std.debug.print(
            "Region: {s} | Active Nodes: {d}\n",
            .{c.region, c.nodes},
        );
    }
}