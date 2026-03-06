const std = @import("std");

pub const StrategyInput = struct {
    campaign: []const u8,
    threat_level: []const u8,
    infrastructure: []const u8,
    predicted_attack: []const u8,
};