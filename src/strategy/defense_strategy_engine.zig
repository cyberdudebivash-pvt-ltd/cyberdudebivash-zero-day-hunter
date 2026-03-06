const std = @import("std");

/// Recommended defensive action
pub const DefenseAction = enum {
    monitor,
    block_ip,
    isolate_host,
    patch_service,
    increase_logging,
    activate_incident_response,
};

/// Strategy recommendation
pub const Strategy = struct {
    target: []const u8,
    action: DefenseAction,
    reason: []const u8,
};

/// Defense Strategy Engine
pub const DefenseStrategyEngine = struct {

    allocator: std.mem.Allocator,

    strategies: std.ArrayList(Strategy),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) DefenseStrategyEngine {
        return .{
            .allocator = allocator,
            .strategies = std.ArrayList(Strategy).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *DefenseStrategyEngine) void {

        for (self.strategies.items) |s| {
            self.allocator.free(s.target);
            self.allocator.free(s.reason);
        }

        self.strategies.deinit();
    }

    /// ------------------------------------------------
    /// ADD STRATEGY
    /// ------------------------------------------------
    pub fn addStrategy(
        self: *DefenseStrategyEngine,
        target: []const u8,
        action: DefenseAction,
        reason: []const u8,
    ) !void {

        const tgt = try self.allocator.dupe(u8, target);
        const rsn = try self.allocator.dupe(u8, reason);

        try self.strategies.append(.{
            .target = tgt,
            .action = action,
            .reason = rsn,
        });

        std.log.info(
            "[DefenseStrategy] Strategy created for {s}",
            .{target},
        );
    }

    /// ------------------------------------------------
    /// ANALYZE THREAT SCORE
    /// ------------------------------------------------
    pub fn analyzeThreatScore(
        self: *DefenseStrategyEngine,
        target: []const u8,
        score: u32,
    ) !void {

        if (score >= 90) {

            try self.addStrategy(
                target,
                .activate_incident_response,
                "Critical threat score detected",
            );

            try self.addStrategy(
                target,
                .isolate_host,
                "Immediate containment required",
            );

        } else if (score >= 60) {

            try self.addStrategy(
                target,
                .block_ip,
                "Malicious activity detected",
            );

        } else if (score >= 30) {

            try self.addStrategy(
                target,
                .increase_logging,
                "Suspicious behavior detected",
            );

        } else {

            try self.addStrategy(
                target,
                .monitor,
                "Low threat level",
            );
        }
    }

    /// ------------------------------------------------
    /// ANALYZE OPEN PORT EXPOSURE
    /// ------------------------------------------------
    pub fn analyzeServices(
        self: *DefenseStrategyEngine,
        target: []const u8,
        ports: []const u16,
    ) !void {

        for (ports) |p| {

            if (p == 22 or p == 3389) {

                try self.addStrategy(
                    target,
                    .increase_logging,
                    "Remote access service exposed",
                );

            }

            if (p == 445) {

                try self.addStrategy(
                    target,
                    .patch_service,
                    "SMB exposure risk detected",
                );

            }

            if (p == 3306) {

                try self.addStrategy(
                    target,
                    .patch_service,
                    "Database exposure detected",
                );

            }
        }
    }

    /// ------------------------------------------------
    /// ANALYZE THREAT WAVE
    /// ------------------------------------------------
    pub fn analyzeWave(
        self: *DefenseStrategyEngine,
        target: []const u8,
        wave_level: []const u8,
    ) !void {

        if (std.mem.eql(u8, wave_level, "surge")) {

            try self.addStrategy(
                target,
                .activate_incident_response,
                "Attack surge predicted",
            );

        } else if (std.mem.eql(u8, wave_level, "rising")) {

            try self.addStrategy(
                target,
                .increase_logging,
                "Threat activity increasing",
            );
        }
    }

    /// ------------------------------------------------
    /// PRINT STRATEGIES
    /// ------------------------------------------------
    pub fn report(self: *DefenseStrategyEngine) void {

        std.log.warn(
            "[DefenseStrategy] Recommended defensive actions",
            .{},
        );

        for (self.strategies.items) |s| {

            std.log.warn(
                "Target={s} Action={} Reason={s}",
                .{ s.target, s.action, s.reason },
            );
        }
    }
};