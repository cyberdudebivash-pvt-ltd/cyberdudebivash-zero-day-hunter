const std = @import("std");

pub const DefenseSignal = struct {
    indicator: []const u8,
    category: []const u8,
    confidence: u8,
};

pub const DefenseAction = struct {
    action_type: []const u8,
    target: []const u8,
    priority: u8,
};