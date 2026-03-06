const std = @import("std");

const Types = @import("hunter_node_types.zig");
const HunterNode = Types.HunterNode;
const HunterTask = Types.HunterTask;

pub fn dispatch(
    nodes: []HunterNode,
    task: HunterTask,
) void {

    for (nodes) |n| {

        std.log.info(
            "dispatching target={s} to node={s}",
            .{ task.target, n.node_id },
        );
    }
}