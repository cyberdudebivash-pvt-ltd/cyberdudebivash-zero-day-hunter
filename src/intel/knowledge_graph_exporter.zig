const std = @import("std");

const Types = @import("knowledge_graph_types.zig");
const KnowledgeGraph = Types.KnowledgeGraph;

pub fn export_json(
    graph: KnowledgeGraph,
) void {

    std.log.info(
        "knowledge graph nodes={} edges={}",
        .{ graph.nodes.len, graph.edges.len },
    );
}