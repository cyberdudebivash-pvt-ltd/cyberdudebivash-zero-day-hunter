const std = @import("std");

pub const TwinState = struct {
    compromised_assets: [][]const u8,
    privilege_level: []const u8,
};