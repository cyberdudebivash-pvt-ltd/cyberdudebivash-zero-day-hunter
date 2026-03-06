const std = @import("std");

pub const ThreatTrend = enum {
    stable,
    increasing,
    decreasing,
    surge,
};

pub const ThreatPrediction = struct {
    region: []const u8,
    predicted_attack_volume: u32,
    confidence: f32,
    trend: ThreatTrend,
    timestamp: i64,
};

pub const ThreatSignal = struct {
    region: []const u8,
    attack_count: u32,
    anomaly_score: f32,
    timestamp: i64,
};

pub const GlobalThreatPredictionModel = struct {
    allocator: std.mem.Allocator,

    signals: std.ArrayList(ThreatSignal),
    predictions: std.ArrayList(ThreatPrediction),

    pub fn init(allocator: std.mem.Allocator) !GlobalThreatPredictionModel {
        return GlobalThreatPredictionModel{
            .allocator = allocator,
            .signals = std.ArrayList(ThreatSignal).init(allocator),
            .predictions = std.ArrayList(ThreatPrediction).init(allocator),
        };
    }

    pub fn deinit(self: *GlobalThreatPredictionModel) void {
        self.signals.deinit();
        self.predictions.deinit();
    }

    pub fn ingestSignal(
        self: *GlobalThreatPredictionModel,
        region: []const u8,
        attack_count: u32,
        anomaly_score: f32,
        timestamp: i64,
    ) !void {
        try self.signals.append(.{
            .region = region,
            .attack_count = attack_count,
            .anomaly_score = anomaly_score,
            .timestamp = timestamp,
        });
    }

    fn analyzeTrend(previous: u32, current: u32) ThreatTrend {
        if (current > previous * 2)
            return .surge;

        if (current > previous)
            return .increasing;

        if (current < previous)
            return .decreasing;

        return .stable;
    }

    fn computeConfidence(anomaly_score: f32) f32 {
        if (anomaly_score > 0.9) return 0.95;
        if (anomaly_score > 0.7) return 0.85;
        if (anomaly_score > 0.5) return 0.70;
        return 0.50;
    }

    pub fn runForecast(self: *GlobalThreatPredictionModel) !void {
        if (self.signals.items.len < 2) return;

        var i: usize = 1;

        while (i < self.signals.items.len) : (i += 1) {

            const prev = self.signals.items[i - 1];
            const curr = self.signals.items[i];

            const trend = analyzeTrend(prev.attack_count, curr.attack_count);

            const predicted_volume: u32 = switch (trend) {
                .surge => curr.attack_count * 2,
                .increasing => curr.attack_count + (curr.attack_count / 2),
                .decreasing => curr.attack_count / 2,
                .stable => curr.attack_count,
            };

            const confidence = computeConfidence(curr.anomaly_score);

            try self.predictions.append(.{
                .region = curr.region,
                .predicted_attack_volume = predicted_volume,
                .confidence = confidence,
                .trend = trend,
                .timestamp = curr.timestamp + 3600,
            });
        }
    }

    pub fn getPredictions(self: *GlobalThreatPredictionModel) []ThreatPrediction {
        return self.predictions.items;
    }

    pub fn clearPredictions(self: *GlobalThreatPredictionModel) void {
        self.predictions.clearRetainingCapacity();
    }
};