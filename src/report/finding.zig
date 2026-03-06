const std = @import("std");

pub const Finding = struct {
    hunter: []const u8,
    finding_type: []const u8,
    severity: []const u8,
    description: []const u8,
};