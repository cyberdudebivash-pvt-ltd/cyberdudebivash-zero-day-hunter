const std = @import("std");

pub const IntelEvent = struct {
    hunter: []const u8,
    detection_type: []const u8,
    severity: []const u8,
    description: []const u8,
    target: []const u8,
};