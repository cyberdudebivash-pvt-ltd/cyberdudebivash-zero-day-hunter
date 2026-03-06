const std = @import("std");

pub const GraphNodeType = enum {
    malware,
    infrastructure,
    vulnerability,
    campaign,
    botnet,
};

pub const GraphNode = struct {
    id: []const u8,
    node_type: GraphNodeType,
    name: []const u8,
};

pub const GraphEdge = struct {
    from: []const u8,
    to: []const u8,
    relation: []const u8,
};