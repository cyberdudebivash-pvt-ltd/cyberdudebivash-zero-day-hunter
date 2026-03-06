const std = @import("std");

/// Threat wave prediction level
pub const WaveLevel = enum {
    stable,
    rising,
    surge,
};

/// Campaign activity snapshot
pub const ActivityPoint = struct {
    timestamp: i64,
    events: u32,
};

/// Prediction result
pub const WavePrediction = struct {
    campaign_id: usize,
    level: WaveLevel,
    growth_rate: f32,
};

/// Threat Wave Predictor
pub const ThreatWavePredictor = struct {

    allocator: std.mem.Allocator,

    /// Campaign activity history
    activity: std.ArrayList(ActivityPoint),

    pub fn init(allocator: std.mem.Allocator) ThreatWavePredictor {
        return .{
            .allocator = allocator,
            .activity = std.ArrayList(ActivityPoint).init(allocator),
        };
    }

    pub fn deinit(self: *ThreatWavePredictor) void {
        self.activity.deinit();
    }

    /// ------------------------------------------------
    /// REGISTER ACTIVITY
    /// ------------------------------------------------
    pub fn recordActivity(
        self: *ThreatWavePredictor,
        timestamp: i64,
        events: u32,
    ) !void {

        try self.activity.append(.{
            .timestamp = timestamp,
            .events = events,
        });

        std.log.info(
            "[ThreatWavePredictor] Activity recorded events={}",
            .{events},
        );
    }

    /// ------------------------------------------------
    /// COMPUTE GROWTH RATE
    /// ------------------------------------------------
    fn computeGrowth(self: *ThreatWavePredictor) f32 {

        if (self.activity.items.len < 2) {
            return 0;
        }

        const last = self.activity.items[self.activity.items.len - 1];
        const prev = self.activity.items[self.activity.items.len - 2];

        if (prev.events == 0) return 0;

        const diff: f32 = @floatFromInt(last.events - prev.events);
        const base: f32 = @floatFromInt(prev.events);

        return diff / base;
    }

    /// ------------------------------------------------
    /// CLASSIFY THREAT WAVE
    /// ------------------------------------------------
    fn classify(growth: f32) WaveLevel {

        if (growth > 1.0) return .surge;
        if (growth > 0.3) return .rising;

        return .stable;
    }

    /// ------------------------------------------------
    /// PREDICT WAVE
    /// ------------------------------------------------
    pub fn predict(
        self: *ThreatWavePredictor,
        campaign_id: usize,
    ) WavePrediction {

        const growth = self.computeGrowth();

        const level = classify(growth);

        return .{
            .campaign_id = campaign_id,
            .level = level,
            .growth_rate = growth,
        };
    }

    /// ------------------------------------------------
    /// SOC ALERT
    /// ------------------------------------------------
    pub fn emit(
        self: *ThreatWavePredictor,
        prediction: WavePrediction,
    ) void {

        std.log.warn(
            "[ThreatWave] campaign={} level={} growth={d:.2}",
            .{
                prediction.campaign_id,
                prediction.level,
                prediction.growth_rate,
            },
        );

        _ = self;
    }
};