const std = @import("std");

pub const StrategySignal = struct {
    indicator: []const u8,
    category: []const u8,
    confidence: u8,
};

pub const StrategyRisk = struct {
    risk_level: u8,
};

pub const DefenseStrategy = struct {
    strategy: []const u8,
    priority: u8,
};