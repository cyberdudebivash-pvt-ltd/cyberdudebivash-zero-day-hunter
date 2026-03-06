const std = @import("std");

pub const IntelEvent = struct {
    indicator: []const u8,
    category: []const u8,
    confidence: u8,
};

pub const IntelFeed = struct {
    events: []IntelEvent,
};