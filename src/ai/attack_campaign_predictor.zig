const std = @import("std");

pub const CampaignSeverity = enum {
    low,
    medium,
    high,
    critical,
};

pub const CampaignType = enum {
    coordinated_scan,
    botnet_wave,
    ransomware_campaign,
    exploitation_wave,
    unknown,
};

pub const ThreatSignal = struct {
    region: []const u8,
    attack_volume: u32,
    anomaly_score: f32,
    timestamp: i64,
};

pub const AttackCampaign = struct {
    campaign_id: u64,
    campaign_type: CampaignType,
    severity: CampaignSeverity,
    regions: []const []const u8,
    predicted_peak_volume: u32,
    confidence: f32,
    start_timestamp: i64,
    predicted_peak_timestamp: i64,
};

pub const AttackCampaignPredictor = struct {
    allocator: std.mem.Allocator,

    signals: std.ArrayList(ThreatSignal),
    campaigns: std.ArrayList(AttackCampaign),

    campaign_counter: u64,

    pub fn init(allocator: std.mem.Allocator) !AttackCampaignPredictor {
        return AttackCampaignPredictor{
            .allocator = allocator,
            .signals = std.ArrayList(ThreatSignal).init(allocator),
            .campaigns = std.ArrayList(AttackCampaign).init(allocator),
            .campaign_counter = 0,
        };
    }

    pub fn deinit(self: *AttackCampaignPredictor) void {
        self.signals.deinit();

        for (self.campaigns.items) |campaign| {
            self.allocator.free(campaign.regions);
        }

        self.campaigns.deinit();
    }

    pub fn ingestSignal(
        self: *AttackCampaignPredictor,
        region: []const u8,
        attack_volume: u32,
        anomaly_score: f32,
        timestamp: i64,
    ) !void {
        try self.signals.append(.{
            .region = region,
            .attack_volume = attack_volume,
            .anomaly_score = anomaly_score,
            .timestamp = timestamp,
        });
    }

    fn computeSeverity(volume: u32, anomaly: f32) CampaignSeverity {
        if (volume > 2000 or anomaly > 0.9)
            return .critical;

        if (volume > 1000 or anomaly > 0.8)
            return .high;

        if (volume > 400 or anomaly > 0.6)
            return .medium;

        return .low;
    }

    fn classifyCampaign(volume: u32, anomaly: f32) CampaignType {
        if (volume > 1500 and anomaly > 0.8)
            return .botnet_wave;

        if (volume > 1000)
            return .coordinated_scan;

        if (anomaly > 0.85)
            return .exploitation_wave;

        return .unknown;
    }

    fn detectMultiRegionSpike(self: *AttackCampaignPredictor) !void {
        if (self.signals.items.len < 3)
            return;

        var region_map = std.StringHashMap(u32).init(self.allocator);
        defer region_map.deinit();

        for (self.signals.items) |signal| {
            const entry = try region_map.getOrPut(signal.region);

            if (!entry.found_existing)
                entry.value_ptr.* = signal.attack_volume
            else
                entry.value_ptr.* += signal.attack_volume;
        }

        if (region_map.count() < 3)
            return;

        var region_list = std.ArrayList([]const u8).init(self.allocator);
        defer region_list.deinit();

        var total_volume: u32 = 0;
        var highest_anomaly: f32 = 0;
        var start_time: i64 = std.math.maxInt(i64);

        var it = region_map.iterator();
        while (it.next()) |entry| {
            try region_list.append(entry.key_ptr.*);
            total_volume += entry.value_ptr.*;

            for (self.signals.items) |s| {
                if (std.mem.eql(u8, s.region, entry.key_ptr.*)) {
                    if (s.anomaly_score > highest_anomaly)
                        highest_anomaly = s.anomaly_score;

                    if (s.timestamp < start_time)
                        start_time = s.timestamp;
                }
            }
        }

        const severity = computeSeverity(total_volume, highest_anomaly);
        const campaign_type = classifyCampaign(total_volume, highest_anomaly);

        const regions = try self.allocator.alloc([]const u8, region_list.items.len);
        std.mem.copy([]const u8, regions, region_list.items);

        self.campaign_counter += 1;

        const campaign = AttackCampaign{
            .campaign_id = self.campaign_counter,
            .campaign_type = campaign_type,
            .severity = severity,
            .regions = regions,
            .predicted_peak_volume = total_volume * 2,
            .confidence = highest_anomaly,
            .start_timestamp = start_time,
            .predicted_peak_timestamp = start_time + 3600,
        };

        try self.campaigns.append(campaign);
    }

    pub fn runCampaignAnalysis(self: *AttackCampaignPredictor) !void {
        try self.detectMultiRegionSpike();
    }

    pub fn getCampaigns(self: *AttackCampaignPredictor) []AttackCampaign {
        return self.campaigns.items;
    }

    pub fn clearCampaigns(self: *AttackCampaignPredictor) void {
        for (self.campaigns.items) |campaign| {
            self.allocator.free(campaign.regions);
        }

        self.campaigns.clearRetainingCapacity();
    }
};