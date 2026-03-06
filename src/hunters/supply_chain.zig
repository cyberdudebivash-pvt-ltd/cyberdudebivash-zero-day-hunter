const std = @import("std");

pub fn run() !void {

    std.debug.print(
        "📦 Supply-Chain Hunter — analyzing dependencies\n",
        .{},
    );
}

pub const plugin = .{
    .name = "supply_chain",
    .run = run,
};