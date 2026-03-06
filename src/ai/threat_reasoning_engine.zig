const std = @import("std");

pub const ReasoningLevel = enum {
    informational,
    suspicious,
    likely_attack,
    confirmed_campaign,
};

pub const ReasoningInput = struct {
    techniques: []const []const u8,
    actor: ?[]const u8,
    campaign: ?[]const u8,
    anomaly_score: f32,
    regional_spread: u32,
};

pub const ReasoningResult = struct {
    inferred_actor: ?[]const u8,
    inferred_campaign: ?[]const u8,
    reasoning_level: ReasoningLevel,
    confidence: f32,
    explanation: []const u8,
};

pub const ThreatReasoningEngine = struct {
    allocator: std.mem.Allocator,

    techniques: std.ArrayList([]const u8),

    current_actor: ?[]const u8,
    current_campaign: ?[]const u8,

    anomaly_score: f32,
    regional_spread: u32,

    result: ?ReasoningResult,

    pub fn init(allocator: std.mem.Allocator) ThreatReasoningEngine {
        return ThreatReasoningEngine{
            .allocator = allocator,
            .techniques = std.ArrayList([]const u8).init(allocator),
            .current_actor = null,
            .current_campaign = null,
            .anomaly_score = 0,
            .regional_spread = 0,
            .result = null,
        };
    }

    pub fn deinit(self: *ThreatReasoningEngine) void {
        self.techniques.deinit();
    }

    pub fn ingestInput(self: *ThreatReasoningEngine, input: ReasoningInput) !void {

        self.techniques.clearRetainingCapacity();

        for (input.techniques) |t| {
            try self.techniques.append(t);
        }

        self.current_actor = input.actor;
        self.current_campaign = input.campaign;
        self.anomaly_score = input.anomaly_score;
        self.regional_spread = input.regional_spread;
    }

    fn computeTechniqueScore(self: *ThreatReasoningEngine) f32 {
        const count = self.techniques.items.len;

        if (count >= 5) return 0.9;
        if (count >= 3) return 0.7;
        if (count >= 1) return 0.4;

        return 0.1;
    }

    fn computeSpreadScore(self: *ThreatReasoningEngine) f32 {

        if (self.regional_spread >= 5) return 0.9;
        if (self.regional_spread >= 3) return 0.7;
        if (self.regional_spread >= 1) return 0.4;

        return 0.1;
    }

    fn determineLevel(score: f32) ReasoningLevel {

        if (score >= 0.85) return .confirmed_campaign;
        if (score >= 0.65) return .likely_attack;
        if (score >= 0.40) return .suspicious;

        return .informational;
    }

    pub fn runReasoning(self: *ThreatReasoningEngine) !void {

        const technique_score = self.computeTechniqueScore();
        const spread_score = self.computeSpreadScore();
        const anomaly_score = self.anomaly_score;

        var confidence =
            (technique_score * 0.4) +
            (spread_score * 0.3) +
            (anomaly_score * 0.3);

        if (confidence > 1.0)
            confidence = 1.0;

        const level = determineLevel(confidence);

        var explanation: []const u8 = "Threat reasoning analysis complete.";

        if (level == .confirmed_campaign) {
            explanation =
                "High confidence coordinated campaign detected.";
        } else if (level == .likely_attack) {
            explanation =
                "Likely attack pattern identified across multiple signals.";
        } else if (level == .suspicious) {
            explanation =
                "Suspicious behavior observed requiring monitoring.";
        }

        self.result = ReasoningResult{
            .inferred_actor = self.current_actor,
            .inferred_campaign = self.current_campaign,
            .reasoning_level = level,
            .confidence = confidence,
            .explanation = explanation,
        };
    }

    pub fn getResult(self: *ThreatReasoningEngine) ?ReasoningResult {
        return self.result;
    }

    pub fn reset(self: *ThreatReasoningEngine) void {

        self.techniques.clearRetainingCapacity();

        self.current_actor = null;
        self.current_campaign = null;
        self.anomaly_score = 0;
        self.regional_spread = 0;

        self.result = null;
    }
};