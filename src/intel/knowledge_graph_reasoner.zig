const std = @import("std");

pub const EntityType = enum {
    actor,
    malware,
    infrastructure,
    vulnerability,
    campaign,
    target,
};

pub const Entity = struct {
    id: []const u8,
    kind: EntityType,
};

pub const Relationship = struct {
    source: []const u8,
    target: []const u8,
    relation: []const u8,
};

pub const Inference = struct {
    description: []const u8,
    confidence: f32,
};

pub const KnowledgeGraphReasoner = struct {

    allocator: std.mem.Allocator,

    entities: std.ArrayList(Entity),
    relationships: std.ArrayList(Relationship),
    inferences: std.ArrayList(Inference),

    pub fn init(allocator: std.mem.Allocator) KnowledgeGraphReasoner {

        return KnowledgeGraphReasoner{
            .allocator = allocator,
            .entities = std.ArrayList(Entity).init(allocator),
            .relationships = std.ArrayList(Relationship).init(allocator),
            .inferences = std.ArrayList(Inference).init(allocator),
        };
    }

    pub fn deinit(self: *KnowledgeGraphReasoner) void {
        self.entities.deinit();
        self.relationships.deinit();
        self.inferences.deinit();
    }

    /// Register entity node
    pub fn addEntity(
        self: *KnowledgeGraphReasoner,
        id: []const u8,
        kind: EntityType,
    ) !void {

        const entity = Entity{
            .id = id,
            .kind = kind,
        };

        try self.entities.append(entity);

        std.log.info(
            "🧩 Entity registered: {s}",
            .{id},
        );
    }

    /// Add relationship edge
    pub fn addRelationship(
        self: *KnowledgeGraphReasoner,
        source: []const u8,
        target: []const u8,
        relation: []const u8,
    ) !void {

        const rel = Relationship{
            .source = source,
            .target = target,
            .relation = relation,
        };

        try self.relationships.append(rel);

        std.log.info(
            "🔗 Relationship added: {s} → {s} ({s})",
            .{ source, target, relation },
        );
    }

    /// Run reasoning on graph
    pub fn runReasoning(self: *KnowledgeGraphReasoner) !void {

        std.log.info(
            "🧠 Running knowledge graph reasoning",
            .{},
        );

        for (self.relationships.items) |rel| {

            if (std.mem.eql(u8, rel.relation, "uses_malware")) {

                const inference = Inference{
                    .description = try std.fmt.allocPrint(
                        self.allocator,
                        "Actor {s} linked to malware {s}",
                        .{ rel.source, rel.target },
                    ),
                    .confidence = 0.8,
                };

                try self.inferences.append(inference);
            }

            if (std.mem.eql(u8, rel.relation, "targets")) {

                const inference = Inference{
                    .description = try std.fmt.allocPrint(
                        self.allocator,
                        "{s} targeting {s} may indicate active campaign",
                        .{ rel.source, rel.target },
                    ),
                    .confidence = 0.7,
                };

                try self.inferences.append(inference);
            }
        }

        std.log.info(
            "🔎 {} intelligence correlations generated",
            .{self.inferences.items.len},
        );
    }

    /// Print reasoning results
    pub fn report(self: *KnowledgeGraphReasoner) void {

        std.log.info(
            "📊 Knowledge Graph Intelligence Report",
            .{},
        );

        for (self.inferences.items) |inf| {

            std.log.info(
                "Inference: {s}",
                .{inf.description},
            );

            std.log.info(
                "Confidence: {d:.2}",
                .{inf.confidence},
            );
        }
    }

    /// Export reasoning output as JSON
    pub fn exportJson(self: *KnowledgeGraphReasoner) ![]u8 {

        var buffer = std.ArrayList(u8).init(self.allocator);

        try buffer.appendSlice("{\"inferences\":[");

        for (self.inferences.items, 0..) |inf, i| {

            if (i != 0)
                try buffer.appendSlice(",");

            const entry = try std.fmt.allocPrint(
                self.allocator,
                "{{\"desc\":\"{s}\",\"confidence\":{d:.2}}}",
                .{
                    inf.description,
                    inf.confidence,
                },
            );

            defer self.allocator.free(entry);

            try buffer.appendSlice(entry);
        }

        try buffer.appendSlice("]}");

        return buffer.toOwnedSlice();
    }
};