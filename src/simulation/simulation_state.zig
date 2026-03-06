const std = @import("std");

pub const SimulationState = struct {
    current_node: []const u8,
    privilege_level: []const u8,
    compromised_assets: [][]const u8,
};