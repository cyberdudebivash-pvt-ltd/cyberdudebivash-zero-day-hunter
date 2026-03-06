const std = @import("std");

const GraphStore = @import("graph_store.zig").GraphStore;
const GraphEdge = @import("graph_types.zig").GraphEdge;

pub fn link(
    store: *GraphStore,
    from: []const u8,
    to: []const u8,
    relation: []const u8,
) !void {

    try store.addEdge(GraphEdge{
        .from = from,
        .to = to,
        .relation = relation,
    });
}