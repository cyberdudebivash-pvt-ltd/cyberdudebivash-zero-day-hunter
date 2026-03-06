const std = @import("std");

/// Host type
pub const HostType = enum {
    server,
    workstation,
    database,
    container,
};

/// Network service
pub const Service = struct {
    name: []const u8,
    port: u16,
};

/// Infrastructure node
pub const Node = struct {
    id: usize,
    hostname: []const u8,
    ip: []const u8,
    kind: HostType,
    services: std.ArrayList(Service),
};

/// Network connection
pub const Link = struct {
    from: usize,
    to: usize,
};

/// Digital Twin Engine
pub const InfrastructureTwin = struct {

    allocator: std.mem.Allocator,

    nodes: std.ArrayList(Node),
    links: std.ArrayList(Link),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) InfrastructureTwin {
        return .{
            .allocator = allocator,
            .nodes = std.ArrayList(Node).init(allocator),
            .links = std.ArrayList(Link).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *InfrastructureTwin) void {

        for (self.nodes.items) |*node| {

            self.allocator.free(node.hostname);
            self.allocator.free(node.ip);

            for (node.services.items) |service| {
                self.allocator.free(service.name);
            }

            node.services.deinit();
        }

        self.nodes.deinit();
        self.links.deinit();
    }

    /// ------------------------------------------------
    /// ADD NODE
    /// ------------------------------------------------
    pub fn addNode(
        self: *InfrastructureTwin,
        hostname: []const u8,
        ip: []const u8,
        kind: HostType,
    ) !usize {

        const host = try self.allocator.dupe(u8, hostname);
        const ip_dup = try self.allocator.dupe(u8, ip);

        const id = self.nodes.items.len;

        var node = Node{
            .id = id,
            .hostname = host,
            .ip = ip_dup,
            .kind = kind,
            .services = std.ArrayList(Service).init(self.allocator),
        };

        try self.nodes.append(node);

        std.log.info(
            "[InfrastructureTwin] Node added {s} ({s})",
            .{ host, ip_dup },
        );

        return id;
    }

    /// ------------------------------------------------
    /// ADD SERVICE
    /// ------------------------------------------------
    pub fn addService(
        self: *InfrastructureTwin,
        node_id: usize,
        name: []const u8,
        port: u16,
    ) !void {

        const svc = try self.allocator.dupe(u8, name);

        try self.nodes.items[node_id].services.append(.{
            .name = svc,
            .port = port,
        });

        std.log.info(
            "[InfrastructureTwin] Service added {s}:{d}",
            .{ name, port },
        );
    }

    /// ------------------------------------------------
    /// CONNECT NODES
    /// ------------------------------------------------
    pub fn connect(
        self: *InfrastructureTwin,
        from: usize,
        to: usize,
    ) !void {

        try self.links.append(.{
            .from = from,
            .to = to,
        });

        std.log.info(
            "[InfrastructureTwin] Link created {} -> {}",
            .{ from, to },
        );
    }

    /// ------------------------------------------------
    /// FIND NODE BY HOSTNAME
    /// ------------------------------------------------
    pub fn findNode(
        self: *InfrastructureTwin,
        hostname: []const u8,
    ) ?usize {

        for (self.nodes.items, 0..) |node, i| {
            if (std.mem.eql(u8, node.hostname, hostname)) {
                return i;
            }
        }

        return null;
    }

    /// ------------------------------------------------
    /// PRINT TOPOLOGY
    /// ------------------------------------------------
    pub fn printTopology(self: *InfrastructureTwin) void {

        std.log.info("[InfrastructureTwin] Network topology", .{});

        for (self.nodes.items) |node| {

            std.log.info(
                "Node {} {s} ({s})",
                .{ node.id, node.hostname, node.ip },
            );

            for (node.services.items) |svc| {

                std.log.info(
                    "  Service {s}:{d}",
                    .{ svc.name, svc.port },
                );
            }
        }

        for (self.links.items) |link| {

            std.log.info(
                "Link {} -> {}",
                .{ link.from, link.to },
            );
        }
    }

    /// ------------------------------------------------
    /// ATTACK SURFACE ANALYSIS
    /// ------------------------------------------------
    pub fn analyzeExposure(self: *InfrastructureTwin) void {

        std.log.warn("[InfrastructureTwin] Exposure analysis", .{});

        for (self.nodes.items) |node| {

            for (node.services.items) |svc| {

                if (svc.port == 22 or svc.port == 3389) {

                    std.log.warn(
                        "Remote access exposed on {s}:{d}",
                        .{ node.hostname, svc.port },
                    );
                }

                if (svc.port == 445) {

                    std.log.warn(
                        "SMB exposure detected on {s}",
                        .{ node.hostname },
                    );
                }

                if (svc.port == 3306) {

                    std.log.warn(
                        "Database exposure detected on {s}",
                        .{ node.hostname },
                    );
                }
            }
        }
    }

    /// ------------------------------------------------
    /// BLAST RADIUS SIMULATION
    /// ------------------------------------------------
    pub fn simulateBreach(
        self: *InfrastructureTwin,
        start_node: usize,
    ) void {

        std.log.warn(
            "[InfrastructureTwin] Breach simulation starting from node {}",
            .{start_node},
        );

        for (self.links.items) |link| {

            if (link.from == start_node) {

                const target = self.nodes.items[link.to];

                std.log.warn(
                    "Potential lateral movement -> {s}",
                    .{target.hostname},
                );
            }
        }
    }
};