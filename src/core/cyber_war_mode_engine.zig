const std = @import("std");

pub const WarMode = enum {
    reconnaissance,
    intrusion,
    escalation,
    infrastructure_attack,
};

pub const WarEvent = struct {
    target: []const u8,
    technique: []const u8,
    stage: WarMode,
};

pub const WarReport = struct {
    targets: usize,
    events: usize,
};

pub const CyberWarModeEngine = struct {

    allocator: std.mem.Allocator,

    targets: std.ArrayList([]const u8),
    events: std.ArrayList(WarEvent),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) CyberWarModeEngine {

        return .{
            .allocator = allocator,
            .targets = std.ArrayList([]const u8).init(allocator),
            .events = std.ArrayList(WarEvent).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *CyberWarModeEngine) void {

        for (self.targets.items) |t| {
            self.allocator.free(t);
        }

        self.targets.deinit();

        for (self.events.items) |e| {
            self.allocator.free(e.target);
            self.allocator.free(e.technique);
        }

        self.events.deinit();
    }

    // ------------------------------------------------
    // ADD TARGET
    // ------------------------------------------------
    pub fn addTarget(
        self: *CyberWarModeEngine,
        target: []const u8,
    ) !void {

        const t = try self.allocator.dupe(u8, target);

        try self.targets.append(t);

        std.log.info(
            "[CyberWar] target added {s}",
            .{ t },
        );
    }

    // ------------------------------------------------
    // GENERATE ATTACK EVENT
    // ------------------------------------------------
    fn generateEvent(
        self: *CyberWarModeEngine,
        target: []const u8,
        technique: []const u8,
        stage: WarMode,
    ) !void {

        const t = try self.allocator.dupe(u8, target);
        const tech = try self.allocator.dupe(u8, technique);

        try self.events.append(.{
            .target = t,
            .technique = tech,
            .stage = stage,
        });

        std.log.warn(
            "[CyberWar] target={s} technique={s} stage={}",
            .{ t, tech, stage },
        );
    }

    // ------------------------------------------------
    // SIMULATE WAR CAMPAIGN
    // ------------------------------------------------
    pub fn simulate(self: *CyberWarModeEngine) !void {

        std.log.warn(
            "[CyberWar] Starting cyber war campaign simulation",
            .{},
        );

        for (self.targets.items) |target| {

            try self.generateEvent(
                target,
                "network_scan",
                .reconnaissance,
            );

            try self.generateEvent(
                target,
                "vulnerability_probe",
                .reconnaissance,
            );

            try self.generateEvent(
                target,
                "exploit_attempt",
                .intrusion,
            );

            try self.generateEvent(
                target,
                "credential_dump",
                .escalation,
            );

            try self.generateEvent(
                target,
                "lateral_move",
                .infrastructure_attack,
            );
        }

        std.log.warn(
            "[CyberWar] Campaign simulation completed",
            .{},
        );
    }

    // ------------------------------------------------
    // REPORT CAMPAIGN
    // ------------------------------------------------
    pub fn report(self: *CyberWarModeEngine) WarReport {

        std.log.warn(
            "========== CYBER WAR REPORT ==========",
            .{},
        );

        for (self.events.items) |e| {

            std.log.warn(
                "Target={s} Technique={s} Stage={}",
                .{
                    e.target,
                    e.technique,
                    e.stage,
                },
            );
        }

        return .{
            .targets = self.targets.items.len,
            .events = self.events.items.len,
        };
    }

    // ------------------------------------------------
    // RESET
    // ------------------------------------------------
    pub fn reset(self: *CyberWarModeEngine) void {

        for (self.events.items) |e| {
            self.allocator.free(e.target);
            self.allocator.free(e.technique);
        }

        self.events.clearRetainingCapacity();
    }
};