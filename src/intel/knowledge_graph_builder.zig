const std = @import("std");

const Types = @import("knowledge_graph_types.zig");
const KGNode = Types.KGNode;
const KGEdge = Types.KGEdge;
const KnowledgeGraph = Types.KnowledgeGraph;
const KGNodeType = Types.KGNodeType;
const KGEdgeType = Types.KGEdgeType;

pub fn build(
    allocator: std.mem.Allocator,
    indicators: [][]const u8,
) !KnowledgeGraph {

    var nodes = std.ArrayList(KGNode).init(allocator);
    var edges = std.ArrayList(KGEdge).init(allocator);

    for (indicators) |i| {

        try nodes.append(.{
            .id = i,
            .node_type = .exploit,
        });
    }

    if (indicators.len > 1) {

        try edges.append(.{
            .from = indicators[0],
            .to = indicators[1],
            .relation = .related_to,
        });
    }

    return KnowledgeGraph{
        .nodes = try nodes.toOwnedSlice(),
        .edges = try edges.toOwnedSlice(),
    };
}