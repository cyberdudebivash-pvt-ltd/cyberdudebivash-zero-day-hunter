const std = @import("std");

pub const NodeType = enum {
    actor,
    campaign,
    technique,
    malware,
    region,
    infrastructure,
};

pub const Node = struct {
    id: u64,
    node_type: NodeType,
    label: []const u8,
};

pub const EdgeType = enum {
    uses,
    targets,
    originates_from,
    related_to,
    delivers,
};

pub const Edge = struct {
    from: u64,
    to: u64,
    edge_type: EdgeType,
    weight: f32,
};

pub const ThreatGraphEngine = struct {
    allocator: std.mem.Allocator,

    nodes: std.ArrayList(Node),
    edges: std.ArrayList(Edge),

    node_index: std.StringHashMap(u64),

    next_node_id: u64,

    pub fn init(allocator: std.mem.Allocator) !ThreatGraphEngine {
        return ThreatGraphEngine{
            .allocator = allocator,
            .nodes = std.ArrayList(Node).init(allocator),
            .edges = std.ArrayList(Edge).init(allocator),
            .node_index = std.StringHashMap(u64).init(allocator),
            .next_node_id = 1,
        };
    }

    pub fn deinit(self: *ThreatGraphEngine) void {
        self.nodes.deinit();
        self.edges.deinit();
        self.node_index.deinit();
    }

    pub fn addNode(
        self: *ThreatGraphEngine,
        node_type: NodeType,
        label: []const u8,
    ) !u64 {

        if (self.node_index.get(label)) |existing| {
            return existing;
        }

        const id = self.next_node_id;
        self.next_node_id += 1;

        try self.nodes.append(.{
            .id = id,
            .node_type = node_type,
            .label = label,
        });

        try self.node_index.put(label, id);

        return id;
    }

    pub fn addEdge(
        self: *ThreatGraphEngine,
        from: u64,
        to: u64,
        edge_type: EdgeType,
        weight: f32,
    ) !void {

        try self.edges.append(.{
            .from = from,
            .to = to,
            .edge_type = edge_type,
            .weight = weight,
        });
    }

    pub fn linkActorTechnique(
        self: *ThreatGraphEngine,
        actor: []const u8,
        technique: []const u8,
    ) !void {

        const actor_id = try self.addNode(.actor, actor);
        const tech_id = try self.addNode(.technique, technique);

        try self.addEdge(actor_id, tech_id, .uses, 1.0);
    }

    pub fn linkCampaignTechnique(
        self: *ThreatGraphEngine,
        campaign: []const u8,
        technique: []const u8,
    ) !void {

        const campaign_id = try self.addNode(.campaign, campaign);
        const tech_id = try self.addNode(.technique, technique);

        try self.addEdge(campaign_id, tech_id, .uses, 1.0);
    }

    pub fn linkCampaignActor(
        self: *ThreatGraphEngine,
        campaign: []const u8,
        actor: []const u8,
    ) !void {

        const campaign_id = try self.addNode(.campaign, campaign);
        const actor_id = try self.addNode(.actor, actor);

        try self.addEdge(actor_id, campaign_id, .related_to, 1.0);
    }

    pub fn linkCampaignRegion(
        self: *ThreatGraphEngine,
        campaign: []const u8,
        region: []const u8,
    ) !void {

        const campaign_id = try self.addNode(.campaign, campaign);
        const region_id = try self.addNode(.region, region);

        try self.addEdge(campaign_id, region_id, .targets, 1.0);
    }

    pub fn linkMalwareCampaign(
        self: *ThreatGraphEngine,
        malware: []const u8,
        campaign: []const u8,
    ) !void {

        const malware_id = try self.addNode(.malware, malware);
        const campaign_id = try self.addNode(.campaign, campaign);

        try self.addEdge(malware_id, campaign_id, .delivers, 1.0);
    }

    pub fn findConnections(
        self: *ThreatGraphEngine,
        label: []const u8,
    ) ![]Edge {

        const id = self.node_index.get(label) orelse return &[_]Edge{};

        var results = std.ArrayList(Edge).init(self.allocator);

        for (self.edges.items) |e| {
            if (e.from == id or e.to == id) {
                try results.append(e);
            }
        }

        return results.toOwnedSlice();
    }

    pub fn nodeCount(self: *ThreatGraphEngine) usize {
        return self.nodes.items.len;
    }

    pub fn edgeCount(self: *ThreatGraphEngine) usize {
        return self.edges.items.len;
    }

    pub fn clear(self: *ThreatGraphEngine) void {
        self.nodes.clearRetainingCapacity();
        self.edges.clearRetainingCapacity();
        self.node_index.clearRetainingCapacity();
        self.next_node_id = 1;
    }
};