const std = @import("std");
const agent = @import("agent.zig");

pub fn main() !void {

    std.debug.print(
        "🚀 CYBERDUDEBIVASH ZERO-DAY HUNTER DISTRIBUTED AGENT\n",
        .{},
    );

    try agent.runAgent();
}