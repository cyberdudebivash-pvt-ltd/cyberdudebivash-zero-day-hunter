const std = @import("std");
const Types = @import("defense_types.zig");

const DefenseSignal = Types.DefenseSignal;
const DefenseAction = Types.DefenseAction;

pub fn recommend_patch(
    allocator: std.mem.Allocator,
    signals: []DefenseSignal,
) ![]DefenseAction {

    var list = std.ArrayList(DefenseAction).init(allocator);

    for (signals) |s| {

        if (std.mem.eql(u8, s.category, "vulnerability")) {

            try list.append(.{
                .action_type = "recommend_patch",
                .target = s.indicator,
                .priority = s.confidence,
            });
        }
    }

    return list.toOwnedSlice();
}