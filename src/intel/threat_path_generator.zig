const std = @import("std");
const KG = @import("knowledge_graph_types.zig");

const AttackPath = @import("threat_simulation_types.zig").AttackPath;

pub fn generate_paths(
    allocator: std.mem.Allocator,
    graph: KG.KnowledgeGraph,
) ![]AttackPath {

    var list = std.ArrayList(AttackPath).init(allocator);

    if (graph.nodes.len < 2)
        return list.toOwnedSlice();

    try list.append(.{
        .entry = graph.nodes[0].id,
        .target = graph.nodes[1].id,
        .steps = 1,
    });

    return list.toOwnedSlice();
}