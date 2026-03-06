const std = @import("std");
const Types = @import("defense_types.zig");

const DefenseSignal = Types.DefenseSignal;
const DefenseAction = Types.DefenseAction;

pub fn recommend(
    allocator: std.mem.Allocator,
    signals: []DefenseSignal,
) ![]DefenseAction {

    var list = std.ArrayList(DefenseAction).init(allocator);

    for (signals) |s| {

        if (std.mem.eql(u8, s.category, "botnet_node")) {

            try list.append(.{
                .action_type = "blacklist_ip",
                .target = s.indicator,
                .priority = s.confidence,
            });
        }
    }

    return list.toOwnedSlice();
}