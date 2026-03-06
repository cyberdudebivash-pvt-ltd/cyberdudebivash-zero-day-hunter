const std = @import("std");

const Types = @import("command_center_types.zig");

const CommandMetric = Types.CommandMetric;
const CommandAlert = Types.CommandAlert;
const CommandState = Types.CommandState;

pub fn build_state(
    allocator: std.mem.Allocator,
    metrics: []CommandMetric,
) !CommandState {

    var alerts = std.ArrayList(CommandAlert).init(allocator);

    for (metrics) |m| {

        if (m.value > 10) {

            try alerts.append(.{
                .message = m.name,
                .severity = 70,
            });
        }
    }

    return CommandState{
        .metrics = metrics,
        .alerts = try alerts.toOwnedSlice(),
    };
}