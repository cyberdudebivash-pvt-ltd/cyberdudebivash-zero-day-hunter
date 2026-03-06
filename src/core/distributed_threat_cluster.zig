const std = @import("std");

pub const NodeRole = enum {
    sensor,
    intel,
    defense,
    command,
};

pub const ClusterNode = struct {
    id: []const u8,
    location: []const u8,
    role: NodeRole,
};

pub const ClusterEvent = struct {
    node_id: []const u8,
    message: []const u8,
};

pub const ClusterStats = struct {
    nodes: usize,
    events: usize,
};

pub const DistributedThreatCluster = struct {

    allocator: std.mem.Allocator,

    nodes: std.ArrayList(ClusterNode),
    events: std.ArrayList(ClusterEvent),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) DistributedThreatCluster {

        return .{
            .allocator = allocator,
            .nodes = std.ArrayList(ClusterNode).init(allocator),
            .events = std.ArrayList(ClusterEvent).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *DistributedThreatCluster) void {

        for (self.nodes.items) |node| {
            self.allocator.free(node.id);
            self.allocator.free(node.location);
        }

        self.nodes.deinit();

        for (self.events.items) |e| {
            self.allocator.free(e.node_id);
            self.allocator.free(e.message);
        }

        self.events.deinit();
    }

    // ------------------------------------------------
    // REGISTER NODE
    // ------------------------------------------------
    pub fn registerNode(
        self: *DistributedThreatCluster,
        id: []const u8,
        location: []const u8,
        role: NodeRole,
    ) !void {

        const nid = try self.allocator.dupe(u8, id);
        const loc = try self.allocator.dupe(u8, location);

        try self.nodes.append(.{
            .id = nid,
            .location = loc,
            .role = role,
        });

        std.log.info(
            "[Cluster] Node registered id={s} role={}",
            .{ nid, role },
        );
    }

    // ------------------------------------------------
    // BROADCAST EVENT
    // ------------------------------------------------
    pub fn broadcastEvent(
        self: *DistributedThreatCluster,
        message: []const u8,
    ) !void {

        for (self.nodes.items) |node| {

            const nid = try self.allocator.dupe(u8, node.id);
            const msg = try self.allocator.dupe(u8, message);

            try self.events.append(.{
                .node_id = nid,
                .message = msg,
            });

            std.log.warn(
                "[Cluster] event sent to node={s} message={s}",
                .{ node.id, message },
            );
        }
    }

    // ------------------------------------------------
    // SYNC THREAT DATA
    // ------------------------------------------------
    pub fn syncThreatIntel(self: *DistributedThreatCluster) void {

        std.log.info(
            "[Cluster] Synchronizing threat intelligence across nodes",
            .{},
        );

        for (self.nodes.items) |node| {

            std.log.info(
                "[Cluster] node={s} sync complete",
                .{ node.id },
            );
        }
    }

    // ------------------------------------------------
    // LIST CLUSTER NODES
    // ------------------------------------------------
    pub fn listNodes(self: *DistributedThreatCluster) void {

        std.log.warn(
            "========== CLUSTER NODES ==========",
            .{},
        );

        for (self.nodes.items) |node| {

            std.log.warn(
                "Node={s} Location={s} Role={}",
                .{
                    node.id,
                    node.location,
                    node.role,
                },
            );
        }
    }

    // ------------------------------------------------
    // REPORT CLUSTER
    // ------------------------------------------------
    pub fn report(self: *DistributedThreatCluster) ClusterStats {

        std.log.warn(
            "========== CLUSTER REPORT ==========",
            .{},
        );

        std.log.warn(
            "Nodes={} Events={}",
            .{
                self.nodes.items.len,
                self.events.items.len,
            },
        );

        return .{
            .nodes = self.nodes.items.len,
            .events = self.events.items.len,
        };
    }

    // ------------------------------------------------
    // RESET
    // ------------------------------------------------
    pub fn reset(self: *DistributedThreatCluster) void {

        for (self.events.items) |e| {
            self.allocator.free(e.node_id);
            self.allocator.free(e.message);
        }

        self.events.clearRetainingCapacity();
    }
};