const std = @import("std");

pub const BehaviorSeverity = enum {
    low,
    medium,
    high,
    critical,
};

pub const BehaviorEvent = struct {
    target: []const u8,
    technique: []const u8,
    timestamp: i64,
};

pub const BehaviorAlert = struct {
    target: []const u8,
    reason: []const u8,
    severity: BehaviorSeverity,
};

pub const ThreatBehaviorAnomalyEngine = struct {

    allocator: std.mem.Allocator,

    events: std.ArrayList(BehaviorEvent),

    alerts: std.ArrayList(BehaviorAlert),

    technique_frequency: std.StringHashMap(u32),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) ThreatBehaviorAnomalyEngine {

        return .{
            .allocator = allocator,
            .events = std.ArrayList(BehaviorEvent).init(allocator),
            .alerts = std.ArrayList(BehaviorAlert).init(allocator),
            .technique_frequency = std.StringHashMap(u32).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *ThreatBehaviorAnomalyEngine) void {

        for (self.events.items) |e| {
            self.allocator.free(e.target);
            self.allocator.free(e.technique);
        }

        self.events.deinit();

        for (self.alerts.items) |a| {
            self.allocator.free(a.target);
            self.allocator.free(a.reason);
        }

        self.alerts.deinit();

        var it = self.technique_frequency.iterator();

        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
        }

        self.technique_frequency.deinit();
    }

    // ------------------------------------------------
    // REGISTER EVENT
    // ------------------------------------------------
    pub fn recordEvent(
        self: *ThreatBehaviorAnomalyEngine,
        target: []const u8,
        technique: []const u8,
    ) !void {

        const t = try self.allocator.dupe(u8, target);
        const tech = try self.allocator.dupe(u8, technique);

        const ts = std.time.timestamp();

        try self.events.append(.{
            .target = t,
            .technique = tech,
            .timestamp = ts,
        });

        try self.updateTechniqueFrequency(tech);

        std.log.info(
            "[BehaviorEngine] Event recorded target={s} technique={s}",
            .{ t, tech },
        );
    }

    // ------------------------------------------------
    // UPDATE TECHNIQUE FREQUENCY
    // ------------------------------------------------
    fn updateTechniqueFrequency(
        self: *ThreatBehaviorAnomalyEngine,
        technique: []const u8,
    ) !void {

        if (self.technique_frequency.get(technique)) |count| {

            try self.technique_frequency.put(
                technique,
                count + 1,
            );

        } else {

            const key = try self.allocator.dupe(u8, technique);

            try self.technique_frequency.put(key, 1);
        }
    }

    // ------------------------------------------------
    // DETECT ANOMALIES
    // ------------------------------------------------
    pub fn analyze(self: *ThreatBehaviorAnomalyEngine) !void {

        std.log.info(
            "[BehaviorEngine] Running anomaly detection",
            .{},
        );

        var it = self.technique_frequency.iterator();

        while (it.next()) |entry| {

            const technique = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (count >= 5) {

                try self.raiseAlert(
                    "global",
                    technique,
                    BehaviorSeverity.high,
                );
            }
        }

        try self.detectRapidAttackChains();
    }

    // ------------------------------------------------
    // RAPID ATTACK CHAIN DETECTION
    // ------------------------------------------------
    fn detectRapidAttackChains(
        self: *ThreatBehaviorAnomalyEngine,
    ) !void {

        if (self.events.items.len < 3) return;

        var i: usize = 0;

        while (i + 2 < self.events.items.len) : (i += 1) {

            const a = self.events.items[i];
            const b = self.events.items[i + 1];
            const c = self.events.items[i + 2];

            if (std.mem.eql(u8, a.target, b.target) and
                std.mem.eql(u8, b.target, c.target))
            {
                const delta = c.timestamp - a.timestamp;

                if (delta < 30) {

                    try self.raiseAlert(
                        a.target,
                        "Rapid multi-stage attack chain detected",
                        BehaviorSeverity.critical,
                    );
                }
            }
        }
    }

    // ------------------------------------------------
    // RAISE ALERT
    // ------------------------------------------------
    fn raiseAlert(
        self: *ThreatBehaviorAnomalyEngine,
        target: []const u8,
        reason: []const u8,
        severity: BehaviorSeverity,
    ) !void {

        const t = try self.allocator.dupe(u8, target);
        const r = try self.allocator.dupe(u8, reason);

        try self.alerts.append(.{
            .target = t,
            .reason = r,
            .severity = severity,
        });

        std.log.warn(
            "[BehaviorEngine] ALERT target={s} severity={}",
            .{ t, severity },
        );
    }

    // ------------------------------------------------
    // REPORT
    // ------------------------------------------------
    pub fn report(self: *ThreatBehaviorAnomalyEngine) void {

        std.log.warn(
            "===== Behavior Anomaly Report =====",
            .{},
        );

        for (self.alerts.items) |a| {

            std.log.warn(
                "Target={s} Severity={} Reason={s}",
                .{
                    a.target,
                    a.severity,
                    a.reason,
                },
            );
        }
    }

    // ------------------------------------------------
    // RESET
    // ------------------------------------------------
    pub fn reset(self: *ThreatBehaviorAnomalyEngine) void {

        for (self.events.items) |e| {
            self.allocator.free(e.target);
            self.allocator.free(e.technique);
        }

        self.events.clearRetainingCapacity();

        for (self.alerts.items) |a| {
            self.allocator.free(a.target);
            self.allocator.free(a.reason);
        }

        self.alerts.clearRetainingCapacity();

        self.technique_frequency.clearRetainingCapacity();
    }
};