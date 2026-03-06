const std = @import("std");

pub const NodeType = enum {
    host,
    service,
    credential,
    vulnerability,
};

pub const GraphNode = struct {
    id: []const u8,
    kind: NodeType,
};

pub const GraphEdge = struct {
    from: []const u8,
    to: []const u8,
    technique: []const u8,
    weight: f64,
};

pub const AttackPath = struct {
    nodes: std.ArrayList([]const u8),
    score: f64,
};

pub const AttackPathGraphEngine = struct {

    allocator: std.mem.Allocator,

    nodes: std.StringHashMap(GraphNode),
    edges: std.ArrayList(GraphEdge),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) AttackPathGraphEngine {

        return .{
            .allocator = allocator,
            .nodes = std.StringHashMap(GraphNode).init(allocator),
            .edges = std.ArrayList(GraphEdge).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *AttackPathGraphEngine) void {

        var it = self.nodes.iterator();

        while (it.next()) |entry| {
            self.allocator.free(entry.value_ptr.id);
        }

        self.nodes.deinit();

        for (self.edges.items) |e| {
            self.allocator.free(e.from);
            self.allocator.free(e.to);
            self.allocator.free(e.technique);
        }

        self.edges.deinit();
    }

    // ------------------------------------------------
    // ADD NODE
    // ------------------------------------------------
    pub fn addNode(
        self: *AttackPathGraphEngine,
        id: []const u8,
        kind: NodeType,
    ) !void {

        if (self.nodes.contains(id)) {
            return;
        }

        const dup = try self.allocator.dupe(u8, id);

        try self.nodes.put(
            dup,
            .{
                .id = dup,
                .kind = kind,
            },
        );

        std.log.info(
            "[AttackGraph] Node added {s}",
            .{dup},
        );
    }

    // ------------------------------------------------
    // ADD EDGE
    // ------------------------------------------------
    pub fn addEdge(
        self: *AttackPathGraphEngine,
        from: []const u8,
        to: []const u8,
        technique: []const u8,
        weight: f64,
    ) !void {

        const f = try self.allocator.dupe(u8, from);
        const t = try self.allocator.dupe(u8, to);
        const tech = try self.allocator.dupe(u8, technique);

        try self.edges.append(.{
            .from = f,
            .to = t,
            .technique = tech,
            .weight = weight,
        });

        std.log.warn(
            "[AttackGraph] Edge {s} -> {s} via {s}",
            .{ f, t, tech },
        );
    }

    // ------------------------------------------------
    // FIND ATTACK PATHS
    // ------------------------------------------------
    pub fn findPaths(
        self: *AttackPathGraphEngine,
        start: []const u8,
        target: []const u8,
    ) !std.ArrayList(AttackPath) {

        var results = std.ArrayList(AttackPath).init(self.allocator);

        for (self.edges.items) |edge| {

            if (std.mem.eql(u8, edge.from, start) and
                std.mem.eql(u8, edge.to, target))
            {
                var path = AttackPath{
                    .nodes = std.ArrayList([]const u8).init(self.allocator),
                    .score = edge.weight,
                };

                try path.nodes.append(edge.from);
                try path.nodes.append(edge.to);

                try results.append(path);
            }
        }

        return results;
    }

    // ------------------------------------------------
    // ANALYZE LATERAL MOVEMENT
    // ------------------------------------------------
    pub fn analyze(self: *AttackPathGraphEngine) void {

        std.log.warn(
            "[AttackGraph] Analyzing attack graph",
            .{},
        );

        for (self.edges.items) |edge| {

            std.log.warn(
                "Path {s} -> {s} technique={s}",
                .{
                    edge.from,
                    edge.to,
                    edge.technique,
                },
            );
        }
    }

    // ------------------------------------------------
    // RENDER ASCII GRAPH
    // ------------------------------------------------
    pub fn renderASCII(self: *AttackPathGraphEngine) void {

        std.log.warn(
            "========= ATTACK PATH GRAPH =========",
            .{},
        );

        for (self.edges.items) |edge| {

            std.log.warn(
                "{s} ---> {s} ({s})",
                .{
                    edge.from,
                    edge.to,
                    edge.technique,
                },
            );
        }
    }

    // ------------------------------------------------
    // RESET
    // ------------------------------------------------
    pub fn reset(self: *AttackPathGraphEngine) void {

        for (self.edges.items) |e| {
            self.allocator.free(e.from);
            self.allocator.free(e.to);
            self.allocator.free(e.technique);
        }

        self.edges.clearRetainingCapacity();
    }
};