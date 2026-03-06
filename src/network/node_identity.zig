const std = @import("std");

pub const NodeIdentity = struct {
    node_id: []const u8,
    region: []const u8,
    organization: []const u8,
};