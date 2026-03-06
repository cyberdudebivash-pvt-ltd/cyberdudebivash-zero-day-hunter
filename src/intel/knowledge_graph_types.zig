const std = @import("std");

pub const KGNodeType = enum {
    target,
    vulnerability,
    botnet_node,
    campaign,
    exploit,
    credential_leak,
};

pub const KGNode = struct {
    id: []const u8,
    node_type: KGNodeType,
};

pub const KGEdgeType = enum {
    exploits,
    controls,
    targets,
    related_to,
};

pub const KGEdge = struct {
    from: []const u8,
    to: []const u8,
    relation: KGEdgeType,
};

pub const KnowledgeGraph = struct {
    nodes: []KGNode,
    edges: []KGEdge,
};