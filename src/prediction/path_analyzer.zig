const std = @import("std");

const GraphStore = @import("../intel_graph/graph_store.zig").GraphStore;

pub fn analyzePaths(
    store: *GraphStore,
) void {

    for (store.edges.items) |edge| {

        std.log.info(
            "Potential attack path: {s} → {s}",
            .{edge.from, edge.to},
        );
    }
}