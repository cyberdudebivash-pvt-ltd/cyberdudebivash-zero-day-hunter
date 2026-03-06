const std = @import("std");

const GraphStore = @import("../intel_graph/graph_store.zig").GraphStore;

pub fn generatePaths(
    store: *GraphStore,
) void {

    for (store.edges.items) |edge| {

        std.log.info(
            "Simulated attack path: {s} → {s}",
            .{edge.from, edge.to},
        );
    }
}