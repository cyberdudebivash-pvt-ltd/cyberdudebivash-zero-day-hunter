const std = @import("std");

pub const ThreatNode = struct {
    id: []const u8,
};

pub const ThreatEdge = struct {
    source: []const u8,
    target: []const u8,
    relation: []const u8,
};

var allocator = std.heap.page_allocator;

var nodes = std.ArrayList(ThreatNode).init(allocator);
var edges = std.ArrayList(ThreatEdge).init(allocator);

pub fn addNode(id: []const u8) !void {

    try nodes.append(.{ .id = id });

    std.debug.print(
        "🧠 Threat graph node added: {s}\n",
        .{id},
    );
}

pub fn addEdge(src: []const u8, dst: []const u8, relation: []const u8) !void {

    try edges.append(.{
        .source = src,
        .target = dst,
        .relation = relation,
    });

    std.debug.print(
        "🔗 Threat relation: {s} → {s} ({s})\n",
        .{ src, dst, relation },
    );
}

pub fn renderGraph() void {

    std.debug.print(
        "\n📊 Real-Time Threat Graph\n",
        .{},
    );

    for (edges.items) |e| {

        std.debug.print(
            "{s} → {s} | relation: {s}\n",
            .{ e.source, e.target, e.relation },
        );
    }
}