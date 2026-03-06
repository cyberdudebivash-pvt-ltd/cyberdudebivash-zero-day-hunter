const std = @import("std");

const Types = @import("knowledge_graph_types.zig");
const KnowledgeGraph = Types.KnowledgeGraph;

pub fn merge(
    allocator: std.mem.Allocator,
    graphs: []KnowledgeGraph,
) !KnowledgeGraph {

    var nodes = std.ArrayList(@TypeOf(graphs[0].nodes[0])).init(allocator);
    var edges = std.ArrayList(@TypeOf(graphs[0].edges[0])).init(allocator);

    for (graphs) |g| {

        for (g.nodes) |n|
            try nodes.append(n);

        for (g.edges) |e|
            try edges.append(e);
    }

    return KnowledgeGraph{
        .nodes = try nodes.toOwnedSlice(),
        .edges = try edges.toOwnedSlice(),
    };
}