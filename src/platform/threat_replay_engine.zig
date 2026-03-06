const std = @import("std");

pub const ReplayEvent = struct {
    attacker_ip: []const u8,
    target: []const u8,
    technique: []const u8,
    severity: []const u8,
    timestamp: i64,
};

pub const ReplayScenario = struct {
    name: []const u8,
    description: []const u8,
    events: std.ArrayList(ReplayEvent),
};

pub const ThreatReplayEngine = struct {

    allocator: std.mem.Allocator,
    scenarios: std.ArrayList(ReplayScenario),

    pub fn init(allocator: std.mem.Allocator) ThreatReplayEngine {
        return ThreatReplayEngine{
            .allocator = allocator,
            .scenarios = std.ArrayList(ReplayScenario).init(allocator),
        };
    }

    pub fn deinit(self: *ThreatReplayEngine) void {

        for (self.scenarios.items) |*scenario| {
            scenario.events.deinit();
        }

        self.scenarios.deinit();
    }

    /// Load a replay scenario
    pub fn createScenario(
        self: *ThreatReplayEngine,
        name: []const u8,
        description: []const u8,
    ) !usize {

        var scenario = ReplayScenario{
            .name = name,
            .description = description,
            .events = std.ArrayList(ReplayEvent).init(self.allocator),
        };

        try self.scenarios.append(scenario);

        std.log.info(
            "🎬 Replay scenario created: {s}",
            .{name},
        );

        return self.scenarios.items.len - 1;
    }

    /// Add attack event to scenario
    pub fn addEvent(
        self: *ThreatReplayEngine,
        scenario_index: usize,
        attacker: []const u8,
        target: []const u8,
        technique: []const u8,
        severity: []const u8,
    ) !void {

        const event = ReplayEvent{
            .attacker_ip = attacker,
            .target = target,
            .technique = technique,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        };

        try self.scenarios.items[scenario_index].events.append(event);

        std.log.info(
            "⚔️ Replay event added: {s} → {s}",
            .{ attacker, target },
        );
    }

    /// Replay attack scenario
    pub fn replayScenario(
        self: *ThreatReplayEngine,
        index: usize,
        delay_seconds: u64,
    ) !void {

        const scenario = &self.scenarios.items[index];

        std.log.info(
            "🎬 Replaying scenario: {s}",
            .{scenario.name},
        );

        for (scenario.events.items) |event| {

            std.log.info(
                "🚨 Attack Replay | {s} → {s} | Technique: {s}",
                .{
                    event.attacker_ip,
                    event.target,
                    event.technique,
                },
            );

            std.log.info(
                "Severity: {s}",
                .{event.severity},
            );

            std.time.sleep(delay_seconds * std.time.ns_per_s);
        }

        std.log.info(
            "✅ Scenario replay completed",
            .{},
        );
    }

    /// Export replay scenario as JSON
    pub fn exportScenario(
        self: *ThreatReplayEngine,
        index: usize,
    ) ![]u8 {

        const scenario = &self.scenarios.items[index];

        var buffer = std.ArrayList(u8).init(self.allocator);

        try buffer.appendSlice("{\"scenario\":\"");
        try buffer.appendSlice(scenario.name);
        try buffer.appendSlice("\",\"events\":[");

        for (scenario.events.items, 0..) |e, i| {

            if (i != 0)
                try buffer.appendSlice(",");

            const entry = try std.fmt.allocPrint(
                self.allocator,
                "{{\"attacker\":\"{s}\",\"target\":\"{s}\",\"technique\":\"{s}\",\"severity\":\"{s}\",\"ts\":{}}}",
                .{
                    e.attacker_ip,
                    e.target,
                    e.technique,
                    e.severity,
                    e.timestamp,
                },
            );

            defer self.allocator.free(entry);

            try buffer.appendSlice(entry);
        }

        try buffer.appendSlice("]}");

        return buffer.toOwnedSlice();
    }
};