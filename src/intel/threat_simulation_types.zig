const std = @import("std");

pub const AttackPath = struct {
    entry: []const u8,
    target: []const u8,
    steps: u32,
};

pub const BreachScenario = struct {
    entry_point: []const u8,
    affected_nodes: u32,
};

pub const BlastRadius = struct {
    compromised_assets: u32,
    severity: u8,
};