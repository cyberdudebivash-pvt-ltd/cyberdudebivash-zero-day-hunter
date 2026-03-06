const std = @import("std");

pub const StreamEvent = struct {
    topic: []const u8,
    payload: []const u8,
};