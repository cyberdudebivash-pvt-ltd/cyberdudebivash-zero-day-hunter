const std = @import("std");

/// Scanner result for a target
pub const ScanResult = struct {
    target: []const u8,
    ip: ?std.net.Address,
    open_ports: std.ArrayList(u16),

    pub fn init(allocator: std.mem.Allocator, target: []const u8) ScanResult {
        return .{
            .target = target,
            .ip = null,
            .open_ports = std.ArrayList(u16).init(allocator),
        };
    }

    pub fn deinit(self: *ScanResult) void {
        self.open_ports.deinit();
    }
};

/// Global scanner responsible for reconnaissance
pub const GlobalScanner = struct {
    allocator: std.mem.Allocator,
    timeout_ms: u64,

    pub fn init(allocator: std.mem.Allocator) GlobalScanner {
        return .{
            .allocator = allocator,
            .timeout_ms = 1500,
        };
    }

    pub fn deinit(self: *GlobalScanner) void {
        _ = self;
    }

    /// Resolve domain → IP
    fn resolveTarget(
        self: *GlobalScanner,
        target: []const u8,
    ) !std.net.Address {

        std.log.info("[Scanner] Resolving target: {s}", .{target});

        var list = try std.net.getAddressList(self.allocator, target, 0);
        defer list.deinit();

        if (list.addrs.len == 0) {
            return error.HostNotFound;
        }

        return list.addrs[0];
    }

    /// Probe a single TCP port
    fn probePort(
        self: *GlobalScanner,
        addr: std.net.Address,
        port: u16,
    ) bool {

        var address = addr;
        address.setPort(port);

        const stream = std.net.tcpConnectToAddress(address) catch {
            return false;
        };

        stream.close();

        _ = self;

        return true;
    }

    /// Scan common ports
    fn scanPorts(
        self: *GlobalScanner,
        result: *ScanResult,
    ) !void {

        const common_ports = [_]u16{
            21, 22, 25, 53, 80, 110,
            143, 443, 445, 3306, 8080,
        };

        const ip = result.ip orelse return;

        for (common_ports) |port| {

            if (self.probePort(ip, port)) {
                try result.open_ports.append(port);

                std.log.info(
                    "[Scanner] Open port detected: {}",
                    .{port},
                );
            }
        }
    }

    /// Scan a single target
    pub fn scanTarget(
        self: *GlobalScanner,
        target: []const u8,
    ) !ScanResult {

        var result = ScanResult.init(self.allocator, target);

        const addr = try self.resolveTarget(target);

        result.ip = addr;

        try self.scanPorts(&result);

        return result;
    }

    /// Scan multiple targets
    pub fn scanTargets(
        self: *GlobalScanner,
        targets: [][]const u8,
    ) !void {

        for (targets) |target| {

            std.log.info(
                "[Scanner] Starting reconnaissance for {s}",
                .{target},
            );

            var result = try self.scanTarget(target);
            defer result.deinit();

            if (result.open_ports.items.len == 0) {

                std.log.info(
                    "[Scanner] No open ports found for {s}",
                    .{target},
                );

            } else {

                std.log.warn(
                    "[Scanner] {s} exposed services:",
                    .{target},
                );

                for (result.open_ports.items) |p| {
                    std.log.warn("  -> {}", .{p});
                }
            }
        }

        std.log.info("[Scanner] Recon cycle complete", .{});
    }
};