const std = @import("std");

pub const IntelEvent = struct {
    source: []const u8,
    campaign: []const u8,
    infrastructure: []const u8,
    severity: []const u8,
    description: []const u8,
};