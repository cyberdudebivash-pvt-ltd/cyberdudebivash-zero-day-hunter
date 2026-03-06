const std = @import("std");

pub const ThreatLevel = enum {
    low,
    guarded,
    elevated,
    high,
    critical,
};

pub const RegionalRisk = struct {
    region: []const u8,
    risk_score: f32,
    threat_level: ThreatLevel,
};

pub const GlobalRiskReport = struct {
    global_score: f32,
    threat_level: ThreatLevel,
    total_attack_volume: u64,
    active_campaigns: u32,
    average_anomaly: f32,
    timestamp: i64,
};

pub const RiskSignal = struct {
    region: []const u8,
    attack_volume: u32,
    anomaly_score: f32,
    campaign_factor: f32,
};

pub const GlobalRiskIndexEngine = struct {
    allocator: std.mem.Allocator,

    signals: std.ArrayList(RiskSignal),
    regional_risk: std.ArrayList(RegionalRisk),

    current_report: ?GlobalRiskReport,

    pub fn init(allocator: std.mem.Allocator) !GlobalRiskIndexEngine {
        return GlobalRiskIndexEngine{
            .allocator = allocator,
            .signals = std.ArrayList(RiskSignal).init(allocator),
            .regional_risk = std.ArrayList(RegionalRisk).init(allocator),
            .current_report = null,
        };
    }

    pub fn deinit(self: *GlobalRiskIndexEngine) void {
        self.signals.deinit();
        self.regional_risk.deinit();
    }

    pub fn ingestSignal(
        self: *GlobalRiskIndexEngine,
        region: []const u8,
        attack_volume: u32,
        anomaly_score: f32,
        campaign_factor: f32,
    ) !void {
        try self.signals.append(.{
            .region = region,
            .attack_volume = attack_volume,
            .anomaly_score = anomaly_score,
            .campaign_factor = campaign_factor,
        });
    }

    fn computeThreatLevel(score: f32) ThreatLevel {
        if (score >= 0.85) return .critical;
        if (score >= 0.65) return .high;
        if (score >= 0.45) return .elevated;
        if (score >= 0.25) return .guarded;
        return .low;
    }

    fn computeRegionalRisk(volume: u32, anomaly: f32, campaign: f32) f32 {
        const v = @as(f32, @floatFromInt(volume)) / 2000.0;
        const risk = (v * 0.5) + (anomaly * 0.3) + (campaign * 0.2);

        if (risk > 1.0)
            return 1.0;

        return risk;
    }

    pub fn calculate(self: *GlobalRiskIndexEngine) !void {
        if (self.signals.items.len == 0)
            return;

        self.regional_risk.clearRetainingCapacity();

        var total_volume: u64 = 0;
        var anomaly_sum: f32 = 0;
        var campaign_count: u32 = 0;

        for (self.signals.items) |signal| {

            const risk = computeRegionalRisk(
                signal.attack_volume,
                signal.anomaly_score,
                signal.campaign_factor,
            );

            const level = computeThreatLevel(risk);

            try self.regional_risk.append(.{
                .region = signal.region,
                .risk_score = risk,
                .threat_level = level,
            });

            total_volume += signal.attack_volume;
            anomaly_sum += signal.anomaly_score;

            if (signal.campaign_factor > 0.5)
                campaign_count += 1;
        }

        const avg_anomaly = anomaly_sum / @as(f32, @floatFromInt(self.signals.items.len));

        const global_volume_factor = @as(f32, @floatFromInt(total_volume)) / 10000.0;
        const campaign_factor = @as(f32, @floatFromInt(campaign_count)) / 10.0;

        var global_score =
            (global_volume_factor * 0.5) +
            (avg_anomaly * 0.3) +
            (campaign_factor * 0.2);

        if (global_score > 1.0)
            global_score = 1.0;

        const level = computeThreatLevel(global_score);

        const timestamp = std.time.timestamp();

        self.current_report = GlobalRiskReport{
            .global_score = global_score,
            .threat_level = level,
            .total_attack_volume = total_volume,
            .active_campaigns = campaign_count,
            .average_anomaly = avg_anomaly,
            .timestamp = timestamp,
        };
    }

    pub fn getRegionalRisk(self: *GlobalRiskIndexEngine) []RegionalRisk {
        return self.regional_risk.items;
    }

    pub fn getGlobalReport(self: *GlobalRiskIndexEngine) ?GlobalRiskReport {
        return self.current_report;
    }

    pub fn clearSignals(self: *GlobalRiskIndexEngine) void {
        self.signals.clearRetainingCapacity();
    }
};