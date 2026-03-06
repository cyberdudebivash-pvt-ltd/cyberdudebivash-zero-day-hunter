const std = @import("std");

pub const ThreatSignal = struct {
    category: []const u8,
    indicator: []const u8,
    confidence: u8,
};

pub const ThreatTrend = struct {
    category: []const u8,
    signal_count: u32,
    avg_confidence: u8,
};

pub const ThreatPrediction = struct {
    threat_type: []const u8,
    predicted_risk: u8,
};