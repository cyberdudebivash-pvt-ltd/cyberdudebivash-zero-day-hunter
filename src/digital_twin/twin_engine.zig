const std = @import("std");

pub const TwinEngine = struct {

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) TwinEngine {
        return .{ .allocator = allocator };
    }

    pub fn deinit(_: *TwinEngine) void {}

    pub fn simulate(_: *TwinEngine) void {

        std.log.info(
            "[TwinEngine] infrastructure simulation running",
            .{},
        );
    }

    pub fn tick(_: *TwinEngine) void {

        std.log.info(
            "[TwinEngine] simulation tick",
            .{},
        );
    }
};