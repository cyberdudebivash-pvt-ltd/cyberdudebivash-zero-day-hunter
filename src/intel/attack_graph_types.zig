const std = @import("std");

pub const NodeType = enum {
    target,
    vulnerability,
    hunter_signal,
    exploit_chain,
};

pub const Node = struct {
    id: []const u8,
    node_type: NodeType,
};

pub const EdgeType = enum {
    detects,
    leads_to,
    affects,
};

pub const Edge = struct {
    from: []const u8,
    to: []const u8,
    edge_type: EdgeType,
};

pub const AttackGraph = struct {
    nodes: []Node,
    edges: []Edge,
};