const std = @import("std");

pub const ThreatActorType = enum {
    apt,
    cybercriminal,
    hacktivist,
    botnet_operator,
    unknown,
};

pub const AttributionConfidence = enum {
    low,
    medium,
    high,
    very_high,
};

pub const ThreatActorProfile = struct {
    name: []const u8,
    actor_type: ThreatActorType,
    known_regions: []const []const u8,
    preferred_attack_volume: u32,
    anomaly_signature: f32,
};

pub const CampaignSignal = struct {
    regions: []const []const u8,
    attack_volume: u32,
    anomaly_score: f32,
    campaign_type: []const u8,
};

pub const AttributionResult = struct {
    actor_name: []const u8,
    actor_type: ThreatActorType,
    confidence: AttributionConfidence,
    score: f32,
};

pub const ThreatActorAttributionEngine = struct {
    allocator: std.mem.Allocator,

    actor_profiles: std.ArrayList(ThreatActorProfile),
    results: std.ArrayList(AttributionResult),

    pub fn init(allocator: std.mem.Allocator) !ThreatActorAttributionEngine {
        var engine = ThreatActorAttributionEngine{
            .allocator = allocator,
            .actor_profiles = std.ArrayList(ThreatActorProfile).init(allocator),
            .results = std.ArrayList(AttributionResult).init(allocator),
        };

        try engine.loadDefaultProfiles();

        return engine;
    }

    pub fn deinit(self: *ThreatActorAttributionEngine) void {
        self.actor_profiles.deinit();
        self.results.deinit();
    }

    fn loadDefaultProfiles(self: *ThreatActorAttributionEngine) !void {

        const apt29_regions = try self.allocator.alloc([]const u8, 3);
        apt29_regions[0] = "EU";
        apt29_regions[1] = "US";
        apt29_regions[2] = "APAC";

        try self.actor_profiles.append(.{
            .name = "APT29",
            .actor_type = .apt,
            .known_regions = apt29_regions,
            .preferred_attack_volume = 1200,
            .anomaly_signature = 0.82,
        });

        const lazarus_regions = try self.allocator.alloc([]const u8, 2);
        lazarus_regions[0] = "APAC";
        lazarus_regions[1] = "US";

        try self.actor_profiles.append(.{
            .name = "Lazarus Group",
            .actor_type = .apt,
            .known_regions = lazarus_regions,
            .preferred_attack_volume = 2000,
            .anomaly_signature = 0.90,
        });

        const botnet_regions = try self.allocator.alloc([]const u8, 3);
        botnet_regions[0] = "GLOBAL";
        botnet_regions[1] = "US";
        botnet_regions[2] = "EU";

        try self.actor_profiles.append(.{
            .name = "Generic Botnet Operator",
            .actor_type = .botnet_operator,
            .known_regions = botnet_regions,
            .preferred_attack_volume = 3000,
            .anomaly_signature = 0.65,
        });
    }

    fn computeRegionMatch(
        actor_regions: []const []const u8,
        campaign_regions: []const []const u8,
    ) f32 {

        var matches: u32 = 0;

        for (campaign_regions) |c| {
            for (actor_regions) |a| {
                if (std.mem.eql(u8, c, a)) {
                    matches += 1;
                    break;
                }
            }
        }

        if (campaign_regions.len == 0)
            return 0;

        return @as(f32, @floatFromInt(matches)) /
            @as(f32, @floatFromInt(campaign_regions.len));
    }

    fn computeVolumeScore(preferred: u32, observed: u32) f32 {

        const p = @as(f32, @floatFromInt(preferred));
        const o = @as(f32, @floatFromInt(observed));

        const diff = std.math.fabs(p - o);

        if (p == 0)
            return 0;

        const score = 1.0 - (diff / p);

        if (score < 0)
            return 0;

        return score;
    }

    fn computeAnomalyScore(signature: f32, observed: f32) f32 {

        const diff = std.math.fabs(signature - observed);

        const score = 1.0 - diff;

        if (score < 0)
            return 0;

        return score;
    }

    fn confidenceFromScore(score: f32) AttributionConfidence {

        if (score >= 0.85) return .very_high;
        if (score >= 0.65) return .high;
        if (score >= 0.45) return .medium;

        return .low;
    }

    pub fn analyzeCampaign(
        self: *ThreatActorAttributionEngine,
        signal: CampaignSignal,
    ) !void {

        self.results.clearRetainingCapacity();

        for (self.actor_profiles.items) |profile| {

            const region_score =
                computeRegionMatch(profile.known_regions, signal.regions);

            const volume_score =
                computeVolumeScore(profile.preferred_attack_volume, signal.attack_volume);

            const anomaly_score =
                computeAnomalyScore(profile.anomaly_signature, signal.anomaly_score);

            const final_score =
                (region_score * 0.4) +
                (volume_score * 0.3) +
                (anomaly_score * 0.3);

            if (final_score < 0.25)
                continue;

            const confidence = confidenceFromScore(final_score);

            try self.results.append(.{
                .actor_name = profile.name,
                .actor_type = profile.actor_type,
                .confidence = confidence,
                .score = final_score,
            });
        }

        std.sort.sort(
            AttributionResult,
            self.results.items,
            {},
            struct {
                fn lessThan(_: void, a: AttributionResult, b: AttributionResult) bool {
                    return a.score > b.score;
                }
            }.lessThan,
        );
    }

    pub fn getResults(self: *ThreatActorAttributionEngine) []AttributionResult {
        return self.results.items;
    }
};