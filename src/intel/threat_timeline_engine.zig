const std = @import("std");

pub const TimelineStage = enum {
    reconnaissance,
    weaponization,
    delivery,
    exploitation,
    persistence,
    lateral_movement,
    command_control,
    exfiltration,
};

pub const TimelineEvent = struct {
    target: []const u8,
    description: []const u8,
    stage: TimelineStage,
    severity: u8,
    timestamp: i64,
};

pub const CampaignTimeline = struct {
    target: []const u8,
    events: std.ArrayList(TimelineEvent),
};

pub const ThreatTimelineEngine = struct {

    allocator: std.mem.Allocator,

    events: std.ArrayList(TimelineEvent),

    campaigns: std.StringHashMap(CampaignTimeline),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) ThreatTimelineEngine {

        return .{
            .allocator = allocator,
            .events = std.ArrayList(TimelineEvent).init(allocator),
            .campaigns = std.StringHashMap(CampaignTimeline).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *ThreatTimelineEngine) void {

        for (self.events.items) |e| {
            self.allocator.free(e.target);
            self.allocator.free(e.description);
        }

        self.events.deinit();

        var it = self.campaigns.iterator();

        while (it.next()) |entry| {

            var timeline = entry.value_ptr;

            for (timeline.events.items) |ev| {
                self.allocator.free(ev.target);
                self.allocator.free(ev.description);
            }

            timeline.events.deinit();

            self.allocator.free(timeline.target);
        }

        self.campaigns.deinit();
    }

    // ------------------------------------------------
    // ADD EVENT
    // ------------------------------------------------
    pub fn addEvent(
        self: *ThreatTimelineEngine,
        target: []const u8,
        description: []const u8,
        stage: TimelineStage,
        severity: u8,
    ) !void {

        const tgt = try self.allocator.dupe(u8, target);
        const desc = try self.allocator.dupe(u8, description);

        const event = TimelineEvent{
            .target = tgt,
            .description = desc,
            .stage = stage,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        };

        try self.events.append(event);

        try self.attachToCampaign(event);

        std.log.info(
            "[ThreatTimeline] Event recorded target={s} stage={}",
            .{ tgt, stage },
        );
    }

    // ------------------------------------------------
    // CAMPAIGN ATTACHMENT
    // ------------------------------------------------
    fn attachToCampaign(
        self: *ThreatTimelineEngine,
        event: TimelineEvent,
    ) !void {

        if (self.campaigns.getPtr(event.target)) |timeline| {

            try timeline.events.append(event);

        } else {

            const tgt = try self.allocator.dupe(u8, event.target);

            var timeline = CampaignTimeline{
                .target = tgt,
                .events = std.ArrayList(TimelineEvent).init(self.allocator),
            };

            try timeline.events.append(event);

            try self.campaigns.put(tgt, timeline);
        }
    }

    // ------------------------------------------------
    // SORT EVENTS BY TIME
    // ------------------------------------------------
    pub fn sortEvents(self: *ThreatTimelineEngine) void {

        std.sort.sort(
            TimelineEvent,
            self.events.items,
            {},
            struct {
                fn less(_: void, a: TimelineEvent, b: TimelineEvent) bool {
                    return a.timestamp < b.timestamp;
                }
            }.less,
        );
    }

    // ------------------------------------------------
    // RECONSTRUCT ATTACK CHAINS
    // ------------------------------------------------
    pub fn analyze(self: *ThreatTimelineEngine) void {

        std.log.warn(
            "[ThreatTimeline] Analyzing attack progression",
            .{},
        );

        var it = self.campaigns.iterator();

        while (it.next()) |entry| {

            const timeline = entry.value_ptr;

            std.log.warn(
                "Campaign target={s} events={}",
                .{ timeline.target, timeline.events.items.len },
            );

            for (timeline.events.items) |ev| {

                std.log.warn(
                    "  stage={} desc={s}",
                    .{ ev.stage, ev.description },
                );
            }
        }
    }

    // ------------------------------------------------
    // TIMELINE REPORT
    // ------------------------------------------------
    pub fn report(self: *ThreatTimelineEngine) void {

        std.log.warn(
            "[ThreatTimeline] Global timeline report",
            .{},
        );

        for (self.events.items) |ev| {

            std.log.warn(
                "Target={s} Stage={} Severity={} Time={}",
                .{
                    ev.target,
                    ev.stage,
                    ev.severity,
                    ev.timestamp,
                },
            );
        }
    }

    // ------------------------------------------------
    // ASCII TIMELINE (SOC VISUALIZATION)
    // ------------------------------------------------
    pub fn renderASCII(self: *ThreatTimelineEngine) void {

        std.log.warn(
            "========== THREAT TIMELINE ==========",
            .{},
        );

        for (self.events.items) |ev| {

            const stage_name = @tagName(ev.stage);

            std.log.warn(
                "{d} | {s:20} | {s:15} | severity={}",
                .{
                    ev.timestamp,
                    ev.target,
                    stage_name,
                    ev.severity,
                },
            );
        }
    }

    // ------------------------------------------------
    // CLEAR EVENTS
    // ------------------------------------------------
    pub fn reset(self: *ThreatTimelineEngine) void {

        for (self.events.items) |e| {
            self.allocator.free(e.target);
            self.allocator.free(e.description);
        }

        self.events.clearRetainingCapacity();
    }
};