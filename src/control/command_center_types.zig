const std = @import("std");

pub const CommandMetric = struct {
    name: []const u8,
    value: u32,
};

pub const CommandAlert = struct {
    message: []const u8,
    severity: u8,
};

pub const CommandState = struct {
    metrics: []CommandMetric,
    alerts: []CommandAlert,
};