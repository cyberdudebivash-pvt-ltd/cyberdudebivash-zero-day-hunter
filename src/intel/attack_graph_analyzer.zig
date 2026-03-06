const std = @import("std");

const Types = @import("attack_graph_types.zig");
const AttackGraph = Types.AttackGraph;
const NodeType = Types.NodeType;

pub const GraphRisk = struct {
    total_nodes: u32,
    total_edges: u32,
    risk_score: u8,
};

pub fn analyze(graph: AttackGraph) GraphRisk {

    var vuln_count: u32 = 0;

    for (graph.nodes) |n| {
        if (n.node_type == NodeType.vulnerability) {
            vuln_count += 1;
        }
    }

    const base_score = vuln_count * 20;

    const score: u8 =
        if (base_score > 100) 100 else @intCast(base_score);

    return GraphRisk{
        .total_nodes = @intCast(graph.nodes.len),
        .total_edges = @intCast(graph.edges.len),
        .risk_score = score,
    };
}