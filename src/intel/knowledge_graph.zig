const std = @import("std");

/// Graph node types
pub const NodeType = enum {
    ip,
    domain,
    malware,
    vulnerability,
    actor,
    campaign,
};

/// Graph node
pub const Node = struct {
    id: []const u8,
    kind: NodeType,
};

/// Relationship types
pub const EdgeType = enum {
    resolves_to,
    hosts,
    communicates_with,
    exploits,
    attributed_to,
    part_of,
};

/// Graph edge
pub const Edge = struct {
    from: usize,
    to: usize,
    relation: EdgeType,
};

/// Knowledge Graph
pub const KnowledgeGraph = struct {

    allocator: std.mem.Allocator,

    nodes: std.ArrayList(Node),
    edges: std.ArrayList(Edge),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) KnowledgeGraph {
        return .{
            .allocator = allocator,
            .nodes = std.ArrayList(Node).init(allocator),
            .edges = std.ArrayList(Edge).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *KnowledgeGraph) void {

        for (self.nodes.items) |node| {
            self.allocator.free(node.id);
        }

        self.nodes.deinit();
        self.edges.deinit();
    }

    /// ------------------------------------------------
    /// ADD NODE
    /// ------------------------------------------------
    pub fn addNode(
        self: *KnowledgeGraph,
        id: []const u8,
        kind: NodeType,
    ) !usize {

        const dup = try self.allocator.dupe(u8, id);

        try self.nodes.append(.{
            .id = dup,
            .kind = kind,
        });

        const index = self.nodes.items.len - 1;

        std.log.info(
            "[KnowledgeGraph] Node added: {s}",
            .{dup},
        );

        return index;
    }

    /// ------------------------------------------------
    /// ADD EDGE
    /// ------------------------------------------------
    pub fn addEdge(
        self: *KnowledgeGraph,
        from: usize,
        to: usize,
        relation: EdgeType,
    ) !void {

        try self.edges.append(.{
            .from = from,
            .to = to,
            .relation = relation,
        });

        std.log.info(
            "[KnowledgeGraph] Edge created {} -> {}",
            .{ from, to },
        );
    }

    /// ------------------------------------------------
    /// FIND NODE
    /// ------------------------------------------------
    pub fn findNode(
        self: *KnowledgeGraph,
        id: []const u8,
    ) ?usize {

        for (self.nodes.items, 0..) |node, i| {
            if (std.mem.eql(u8, node.id, id)) {
                return i;
            }
        }

        return null;
    }

    /// ------------------------------------------------
    /// GET CONNECTIONS
    /// ------------------------------------------------
    pub fn connections(
        self: *KnowledgeGraph,
        node_index: usize,
    ) void {

        const node = self.nodes.items[node_index];

        std.log.info(
            "[KnowledgeGraph] Connections for {s}",
            .{node.id},
        );

        for (self.edges.items) |edge| {

            if (edge.from == node_index) {

                const target = self.nodes.items[edge.to];

                std.log.info(
                    " -> {s}",
                    .{target.id},
                );
            }
        }
    }

    /// ------------------------------------------------
    /// PRINT GRAPH
    /// ------------------------------------------------
    pub fn printGraph(self: *KnowledgeGraph) void {

        std.log.info(
            "[KnowledgeGraph] Graph summary",
            .{},
        );

        for (self.nodes.items, 0..) |node, i| {

            std.log.info(
                "Node {}: {s}",
                .{ i, node.id },
            );
        }

        for (self.edges.items) |edge| {

            const from = self.nodes.items[edge.from];
            const to = self.nodes.items[edge.to];

            std.log.info(
                "Edge: {s} -> {s}",
                .{ from.id, to.id },
            );
        }
    }
};