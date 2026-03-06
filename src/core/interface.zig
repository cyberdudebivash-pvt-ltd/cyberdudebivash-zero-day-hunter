const std = @import("std");

pub const Hunter = struct {
    name: []const u8,
    run: *const fn () anyerror!void,
};