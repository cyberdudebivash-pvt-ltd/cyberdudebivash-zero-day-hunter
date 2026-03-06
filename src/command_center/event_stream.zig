const std = @import("std");

pub const CommandEvent = struct {
    source: []const u8,
    event_type: []const u8,
    severity: []const u8,
    description: []const u8,
};