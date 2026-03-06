const std = @import("std");

const Types = @import("attack_graph_types.zig");
const Node = Types.Node;
const Edge = Types.Edge;
const AttackGraph = Types.AttackGraph;
const NodeType = Types.NodeType;
const EdgeType = Types.EdgeType;

const Finding = @import("signal_correlator.zig").Finding;

pub fn build(
    allocator: std.mem.Allocator,
    findings: []Finding,
) !AttackGraph {

    var nodes = std.ArrayList(Node).init(allocator);
    var edges = std.ArrayList(Edge).init(allocator);

    for (findings) |f| {

        try nodes.append(.{
            .id = f.target,
            .node_type = .target,
        });

        try nodes.append(.{
            .id = f.issue,
            .node_type = .hunter_signal,
        });

        try edges.append(.{
            .from = f.target,
            .to = f.issue,
            .edge_type = .detects,
        });
    }

    return AttackGraph{
        .nodes = try nodes.toOwnedSlice(),
        .edges = try edges.toOwnedSlice(),
    };
}