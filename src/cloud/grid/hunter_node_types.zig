const std = @import("std");

pub const HunterNode = struct {
    node_id: []const u8,
    region: []const u8,
};

pub const HunterTask = struct {
    target: []const u8,
};

pub const HunterResult = struct {
    node_id: []const u8,
    target: []const u8,
    status: []const u8,
};