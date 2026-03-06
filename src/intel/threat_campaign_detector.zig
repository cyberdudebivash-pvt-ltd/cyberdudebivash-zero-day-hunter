const std = @import("std");

pub const AttackEvent = struct {
    attacker: []const u8,
    infrastructure: []const u8,
    target: []const u8,
    malware: []const u8,
    timestamp: i64,
};

pub const Campaign = struct {
    name: []const u8,
    attacker: []const u8,
    targets: std.ArrayList([]const u8),
    infrastructure: std.ArrayList([]const u8),
    malware_families: std.ArrayList([]const u8),
    confidence: f32,
};

pub const ThreatCampaignDetector = struct {

    allocator: std.mem.Allocator,

    events: std.ArrayList(AttackEvent),
    campaigns: std.ArrayList(Campaign),

    pub fn init(allocator: std.mem.Allocator) ThreatCampaignDetector {

        return ThreatCampaignDetector{
            .allocator = allocator,
            .events = std.ArrayList(AttackEvent).init(allocator),
            .campaigns = std.ArrayList(Campaign).init(allocator),
        };
    }

    pub fn deinit(self: *ThreatCampaignDetector) void {

        for (self.campaigns.items) |*c| {
            c.targets.deinit();
            c.infrastructure.deinit();
            c.malware_families.deinit();
        }

        self.events.deinit();
        self.campaigns.deinit();
    }

    /// ingest attack telemetry
    pub fn ingestEvent(
        self: *ThreatCampaignDetector,
        attacker: []const u8,
        infra: []const u8,
        target: []const u8,
        malware: []const u8,
    ) !void {

        const event = AttackEvent{
            .attacker = attacker,
            .infrastructure = infra,
            .target = target,
            .malware = malware,
            .timestamp = std.time.timestamp(),
        };

        try self.events.append(event);

        std.log.info(
            "📡 Attack signal recorded: {s} → {s}",
            .{ attacker, target },
        );
    }

    /// detect campaigns from events
    pub fn detectCampaigns(self: *ThreatCampaignDetector) !void {

        std.log.info(
            "🧠 Running campaign detection analysis",
            .{},
        );

        var actor_map =
            std.StringHashMap(*Campaign).init(self.allocator);
        defer actor_map.deinit();

        for (self.events.items) |event| {

            const entry = try actor_map.getOrPut(event.attacker);

            if (!entry.found_existing) {

                var campaign = Campaign{
                    .name = event.attacker,
                    .attacker = event.attacker,
                    .targets = std.ArrayList([]const u8).init(self.allocator),
                    .infrastructure = std.ArrayList([]const u8).init(self.allocator),
                    .malware_families = std.ArrayList([]const u8).init(self.allocator),
                    .confidence = 0,
                };

                try self.campaigns.append(campaign);

                entry.value_ptr.* =
                    &self.campaigns.items[self.campaigns.items.len - 1];
            }

            const camp = entry.value_ptr.*;

            try camp.targets.append(event.target);
            try camp.infrastructure.append(event.infrastructure);
            try camp.malware_families.append(event.malware);

            camp.confidence += 0.2;
        }

        std.log.info(
            "🎯 {} campaigns identified",
            .{self.campaigns.items.len},
        );
    }

    /// normalize confidence scores
    pub fn calculateConfidence(self: *ThreatCampaignDetector) void {

        for (self.campaigns.items) |*camp| {

            if (camp.confidence > 1.0)
                camp.confidence = 1.0;

            std.log.warn(
                "⚠️ Campaign detected: {s} (confidence {d:.2})",
                .{ camp.attacker, camp.confidence },
            );
        }
    }

    /// print campaign report
    pub fn report(self: *ThreatCampaignDetector) void {

        std.log.info(
            "📊 Threat Campaign Intelligence",
            .{},
        );

        for (self.campaigns.items) |camp| {

            std.log.info(
                "Campaign: {s}",
                .{camp.attacker},
            );

            std.log.info(
                "Confidence: {d:.2}",
                .{camp.confidence},
            );

            std.log.info("Targets:", .{});
            for (camp.targets.items) |t| {
                std.log.info(" - {s}", .{t});
            }

            std.log.info("Infrastructure:", .{});
            for (camp.infrastructure.items) |i| {
                std.log.info(" - {s}", .{i});
            }

            std.log.info("Malware:", .{});
            for (camp.malware_families.items) |m| {
                std.log.info(" - {s}", .{m});
            }
        }
    }

    /// export campaigns as JSON
    pub fn exportJson(self: *ThreatCampaignDetector) ![]u8 {

        var buffer = std.ArrayList(u8).init(self.allocator);

        try buffer.appendSlice("{\"campaigns\":[");

        for (self.campaigns.items, 0..) |camp, i| {

            if (i != 0)
                try buffer.appendSlice(",");

            const entry = try std.fmt.allocPrint(
                self.allocator,
                "{{\"campaign\":\"{s}\",\"confidence\":{d:.2}}}",
                .{
                    camp.attacker,
                    camp.confidence,
                },
            );

            defer self.allocator.free(entry);

            try buffer.appendSlice(entry);
        }

        try buffer.appendSlice("]}");

        return buffer.toOwnedSlice();
    }
};