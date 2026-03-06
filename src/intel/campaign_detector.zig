const std = @import("std");

/// Campaign severity
pub const CampaignLevel = enum {
    low,
    medium,
    high,
    critical,
};

/// Event signal entering the campaign engine
pub const Event = struct {
    target: []const u8,
    indicator: []const u8,
    timestamp: i64,
};

/// Detected campaign
pub const Campaign = struct {
    id: usize,
    name: []const u8,
    indicators: std.ArrayList([]const u8),
    targets: std.ArrayList([]const u8),
    level: CampaignLevel,

    pub fn init(
        allocator: std.mem.Allocator,
        id: usize,
        name: []const u8,
    ) !Campaign {

        const name_dup = try allocator.dupe(u8, name);

        return .{
            .id = id,
            .name = name_dup,
            .indicators = std.ArrayList([]const u8).init(allocator),
            .targets = std.ArrayList([]const u8).init(allocator),
            .level = .low,
        };
    }

    pub fn deinit(self: *Campaign, allocator: std.mem.Allocator) void {

        allocator.free(self.name);

        for (self.indicators.items) |i| {
            allocator.free(i);
        }

        for (self.targets.items) |t| {
            allocator.free(t);
        }

        self.indicators.deinit();
        self.targets.deinit();
    }
};

/// Campaign Detector
pub const CampaignDetector = struct {

    allocator: std.mem.Allocator,
    campaigns: std.ArrayList(Campaign),
    events: std.ArrayList(Event),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) CampaignDetector {
        return .{
            .allocator = allocator,
            .campaigns = std.ArrayList(Campaign).init(allocator),
            .events = std.ArrayList(Event).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *CampaignDetector) void {

        for (self.campaigns.items) |*campaign| {
            campaign.deinit(self.allocator);
        }

        self.campaigns.deinit();
        self.events.deinit();
    }

    /// ------------------------------------------------
    /// REGISTER EVENT
    /// ------------------------------------------------
    pub fn addEvent(
        self: *CampaignDetector,
        target: []const u8,
        indicator: []const u8,
        timestamp: i64,
    ) !void {

        try self.events.append(.{
            .target = target,
            .indicator = indicator,
            .timestamp = timestamp,
        });

        std.log.info(
            "[CampaignDetector] Event registered: {s}",
            .{indicator},
        );
    }

    /// ------------------------------------------------
    /// FIND CAMPAIGN BY INDICATOR
    /// ------------------------------------------------
    fn findCampaign(
        self: *CampaignDetector,
        indicator: []const u8,
    ) ?usize {

        for (self.campaigns.items, 0..) |campaign, idx| {

            for (campaign.indicators.items) |ioc| {
                if (std.mem.eql(u8, ioc, indicator)) {
                    return idx;
                }
            }
        }

        return null;
    }

    /// ------------------------------------------------
    /// CREATE NEW CAMPAIGN
    /// ------------------------------------------------
    fn createCampaign(
        self: *CampaignDetector,
        indicator: []const u8,
        target: []const u8,
    ) !void {

        const id = self.campaigns.items.len;

        var campaign = try Campaign.init(
            self.allocator,
            id,
            "Detected Campaign",
        );

        const ioc_dup = try self.allocator.dupe(u8, indicator);
        const tgt_dup = try self.allocator.dupe(u8, target);

        try campaign.indicators.append(ioc_dup);
        try campaign.targets.append(tgt_dup);

        try self.campaigns.append(campaign);

        std.log.warn(
            "[CampaignDetector] New campaign created id={}",
            .{id},
        );
    }

    /// ------------------------------------------------
    /// UPDATE CAMPAIGN
    /// ------------------------------------------------
    fn updateCampaign(
        self: *CampaignDetector,
        index: usize,
        target: []const u8,
    ) !void {

        var campaign = &self.campaigns.items[index];

        const tgt_dup = try self.allocator.dupe(u8, target);
        try campaign.targets.append(tgt_dup);

        if (campaign.targets.items.len > 5) {
            campaign.level = .high;
        }

        if (campaign.targets.items.len > 10) {
            campaign.level = .critical;
        }

        std.log.warn(
            "[CampaignDetector] Campaign {} updated targets={}",
            .{ index, campaign.targets.items.len },
        );
    }

    /// ------------------------------------------------
    /// PROCESS EVENTS
    /// ------------------------------------------------
    pub fn analyze(self: *CampaignDetector) !void {

        for (self.events.items) |event| {

            if (self.findCampaign(event.indicator)) |idx| {

                try self.updateCampaign(
                    idx,
                    event.target,
                );

            } else {

                try self.createCampaign(
                    event.indicator,
                    event.target,
                );
            }
        }

        std.log.info(
            "[CampaignDetector] Analysis complete campaigns={}",
            .{self.campaigns.items.len},
        );
    }

    /// ------------------------------------------------
    /// PRINT CAMPAIGNS
    /// ------------------------------------------------
    pub fn report(self: *CampaignDetector) void {

        std.log.info(
            "[CampaignDetector] Campaign summary",
            .{},
        );

        for (self.campaigns.items) |campaign| {

            std.log.warn(
                "Campaign {} level={}",
                .{ campaign.id, campaign.level },
            );

            std.log.info(
                "Targets impacted: {}",
                .{campaign.targets.items.len},
            );

            for (campaign.targets.items) |t| {
                std.log.info(" -> {s}", .{t});
            }
        }
    }
};