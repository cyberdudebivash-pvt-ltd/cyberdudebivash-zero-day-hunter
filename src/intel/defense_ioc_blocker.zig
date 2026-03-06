const std = @import("std");
const Types = @import("defense_types.zig");

const DefenseSignal = Types.DefenseSignal;
const DefenseAction = Types.DefenseAction;

pub fn generate(
    allocator: std.mem.Allocator,
    signals: []DefenseSignal,
) ![]DefenseAction {

    var actions = std.ArrayList(DefenseAction).init(allocator);

    for (signals) |s| {

        if (std.mem.eql(u8, s.category, "malicious_ip")) {

            try actions.append(.{
                .action_type = "block_ip",
                .target = s.indicator,
                .priority = s.confidence,
            });
        }
    }

    return actions.toOwnedSlice();
}