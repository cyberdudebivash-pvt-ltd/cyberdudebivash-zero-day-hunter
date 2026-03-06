const std = @import("std");

const GraphStore = @import("graph_store.zig").GraphStore;

pub fn findConnections(
    store: *GraphStore,
    node_id: []const u8,
) void {

    for (store.edges.items) |edge| {

        if (std.mem.eql(u8, edge.from, node_id) or
            std.mem.eql(u8, edge.to, node_id))
        {
            std.log.info(
                "Graph relation: {s} -> {s} ({s})",
                .{edge.from, edge.to, edge.relation},
            );
        }
    }
}