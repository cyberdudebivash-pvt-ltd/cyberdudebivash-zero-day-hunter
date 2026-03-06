const std = @import("std");

/// Campaign prediction confidence
pub const PredictionLevel = enum {
    low,
    medium,
    high,
};

/// Observed campaign signal
pub const CampaignSignal = struct {
    target: []const u8,
    indicator: []const u8,
    severity: u8,
    timestamp: i64,
};

/// Prediction result
pub const CampaignPrediction = struct {
    target: []const u8,
    likelihood: PredictionLevel,
    reasoning: []const u8,
};

/// Threat Campaign Predictor
pub const ThreatCampaignPredictor = struct {

    allocator: std.mem.Allocator,

    signals: std.ArrayList(CampaignSignal),
    predictions: std.ArrayList(CampaignPrediction),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) ThreatCampaignPredictor {

        return .{
            .allocator = allocator,
            .signals = std.ArrayList(CampaignSignal).init(allocator),
            .predictions = std.ArrayList(CampaignPrediction).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *ThreatCampaignPredictor) void {

        for (self.signals.items) |s| {
            self.allocator.free(s.target);
            self.allocator.free(s.indicator);
        }

        for (self.predictions.items) |p| {
            self.allocator.free(p.target);
            self.allocator.free(p.reasoning);
        }

        self.signals.deinit();
        self.predictions.deinit();
    }

    /// ------------------------------------------------
    /// ADD CAMPAIGN SIGNAL
    /// ------------------------------------------------
    pub fn addSignal(
        self: *ThreatCampaignPredictor,
        target: []const u8,
        indicator: []const u8,
        severity: u8,
    ) !void {

        const tgt = try self.allocator.dupe(u8, target);
        const ind = try self.allocator.dupe(u8, indicator);

        try self.signals.append(.{
            .target = tgt,
            .indicator = ind,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        });

        std.log.info(
            "[CampaignPredictor] Signal recorded target={s}",
            .{tgt},
        );
    }

    /// ------------------------------------------------
    /// PREDICT CAMPAIGNS
    /// ------------------------------------------------
    pub fn analyze(self: *ThreatCampaignPredictor) !void {

        std.log.warn(
            "[CampaignPredictor] Campaign prediction analysis",
            .{},
        );

        for (self.signals.items) |signal| {

            var level: PredictionLevel = .low;
            var message: []const u8 = "Low probability campaign activity";

            if (signal.severity >= 80) {

                level = .high;
                message = "High likelihood of coordinated campaign";

            } else if (signal.severity >= 50) {

                level = .medium;
                message = "Possible campaign preparation detected";
            }

            const tgt = try self.allocator.dupe(u8, signal.target);
            const reason = try self.allocator.dupe(u8, message);

            try self.predictions.append(.{
                .target = tgt,
                .likelihood = level,
                .reasoning = reason,
            });

            std.log.warn(
                "[CampaignPredictor] Prediction target={s} likelihood={}",
                .{ tgt, level },
            );
        }
    }

    /// ------------------------------------------------
    /// TREND ANALYSIS
    /// ------------------------------------------------
    pub fn analyzeTrends(self: *ThreatCampaignPredictor) void {

        std.log.warn(
            "[CampaignPredictor] Trend analysis",
            .{},
        );

        var high_count: usize = 0;

        for (self.signals.items) |signal| {

            if (signal.severity > 70) {
                high_count += 1;
            }
        }

        if (high_count > 5) {

            std.log.warn(
                "Campaign escalation trend detected events={}",
                .{high_count},
            );
        }
    }

    /// ------------------------------------------------
    /// REPORT
    /// ------------------------------------------------
    pub fn report(self: *ThreatCampaignPredictor) void {

        std.log.warn(
            "[CampaignPredictor] Prediction report",
            .{},
        );

        for (self.predictions.items) |prediction| {

            std.log.warn(
                "Target={s} Likelihood={} Reason={s}",
                .{
                    prediction.target,
                    prediction.likelihood,
                    prediction.reasoning,
                },
            );
        }
    }
};