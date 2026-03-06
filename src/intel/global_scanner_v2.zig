const std = @import("std");

/// Port scan result
pub const PortResult = struct {
    port: u16,
    open: bool,
};

/// Target scan result
pub const ScanResult = struct {
    target: []const u8,
    ports: std.ArrayList(PortResult),
};

/// Scanner configuration
pub const ScannerConfig = struct {
    timeout_ms: u64 = 2000,
    max_ports: u16 = 1024,
};

/// Global Scanner v2
pub const GlobalScannerV2 = struct {

    allocator: std.mem.Allocator,

    config: ScannerConfig,

    results: std.ArrayList(ScanResult),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
        config: ScannerConfig,
    ) GlobalScannerV2 {

        return .{
            .allocator = allocator,
            .config = config,
            .results = std.ArrayList(ScanResult).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *GlobalScannerV2) void {

        for (self.results.items) |*r| {

            self.allocator.free(r.target);
            r.ports.deinit();
        }

        self.results.deinit();
    }

    /// ------------------------------------------------
    /// SCAN TARGET
    /// ------------------------------------------------
    pub fn scanTarget(
        self: *GlobalScannerV2,
        target: []const u8,
    ) !void {

        std.log.info(
            "[GlobalScanner] scanning target {s}",
            .{target},
        );

        const target_dup = try self.allocator.dupe(u8, target);

        var result = ScanResult{
            .target = target_dup,
            .ports = std.ArrayList(PortResult).init(self.allocator),
        };

        var port: u16 = 1;

        while (port <= self.config.max_ports) : (port += 1) {

            const open = self.probePort(target, port);

            if (open) {

                try result.ports.append(.{
                    .port = port,
                    .open = true,
                });

                std.log.info(
                    "[GlobalScanner] open port detected {d} on {s}",
                    .{ port, target },
                );
            }
        }

        try self.results.append(result);
    }

    /// ------------------------------------------------
    /// PORT PROBE
    /// ------------------------------------------------
    fn probePort(
        self: *GlobalScannerV2,
        target: []const u8,
        port: u16,
    ) bool {

        _ = self;

        const address = std.net.Address.parseIp4(target, port) catch return false;

        const timeout = self.config.timeout_ms * std.time.ns_per_ms;

        const result = std.net.tcpConnectToAddressTimeout(
            address,
            timeout,
        );

        if (result) |stream| {

            stream.close();

            return true;

        } else |_| {

            return false;
        }
    }

    /// ------------------------------------------------
    /// SCAN MULTIPLE TARGETS
    /// ------------------------------------------------
    pub fn scanTargets(
        self: *GlobalScannerV2,
        targets: [][]const u8,
    ) !void {

        for (targets) |target| {

            try self.scanTarget(target);
        }
    }

    /// ------------------------------------------------
    /// REPORT RESULTS
    /// ------------------------------------------------
    pub fn report(self: *GlobalScannerV2) void {

        std.log.warn("[GlobalScanner] Scan report", .{});

        for (self.results.items) |result| {

            std.log.warn(
                "Target {s}",
                .{result.target},
            );

            for (result.ports.items) |p| {

                std.log.info(
                    " -> port {d} open",
                    .{p.port},
                );
            }
        }
    }
};