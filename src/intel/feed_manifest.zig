const std = @import("std");

pub const FeedEntry = struct {
    name: []const u8,
    url: []const u8,
    category: []const u8,
};