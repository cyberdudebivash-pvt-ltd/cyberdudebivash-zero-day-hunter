const std = @import("std");

const Types = @import("hunter_node_types.zig");
const HunterTask = Types.HunterTask;
const HunterResult = Types.HunterResult;

pub fn execute(
    node_id: []const u8,
    task: HunterTask,
) HunterResult {

    std.log.info(
        "node={s} scanning target={s}",
        .{ node_id, task.target },
    );

    return HunterResult{
        .node_id = node_id,
        .target = task.target,
        .status = "scan_complete",
    };
}