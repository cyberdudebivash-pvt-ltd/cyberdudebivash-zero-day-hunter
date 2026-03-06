const std = @import("std");

const Types = @import("hunter_node_types.zig");
const HunterResult = Types.HunterResult;

pub fn collect(
    results: []HunterResult,
) void {

    for (results) |r| {

        std.log.info(
            "result node={s} target={s} status={s}",
            .{ r.node_id, r.target, r.status },
        );
    }
}