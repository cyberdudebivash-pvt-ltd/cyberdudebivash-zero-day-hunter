const std = @import("std");

pub const DetectionRule = struct {
    id: []const u8,
    hunter: []const u8,
    pattern: []const u8,
    severity: []const u8,
    description: []const u8,
};