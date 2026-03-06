const std = @import("std");

const Types = @import("command_center_types.zig");
const CommandState = Types.CommandState;

pub fn render(state: CommandState) void {

    std.log.info("=== CYBERDUDEBIVASH COMMAND CENTER ===", .{});

    for (state.metrics) |m| {

        std.log.info(
            "metric: {s} value={}",
            .{ m.name, m.value },
        );
    }

    for (state.alerts) |a| {

        std.log.warn(
            "alert: {s} severity={}",
            .{ a.message, a.severity },
        );
    }
}