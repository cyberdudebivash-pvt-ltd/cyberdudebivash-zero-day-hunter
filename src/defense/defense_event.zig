const std = @import("std");

pub const DefenseEvent = struct {
    target: []const u8,
    infrastructure: []const u8,
    threat_type: []const u8,
    severity: []const u8,
};