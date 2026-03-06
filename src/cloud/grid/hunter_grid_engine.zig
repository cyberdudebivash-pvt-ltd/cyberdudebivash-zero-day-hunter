const std = @import("std");

const Registry = @import("hunter_grid_registry.zig");
const Dispatcher = @import("hunter_grid_dispatcher.zig");

const Types = @import("hunter_node_types.zig");
const HunterTask = Types.HunterTask;

pub fn run(
    allocator: std.mem.Allocator,
) !void {

    const nodes = try Registry.register(allocator);

    const task = HunterTask{
        .target = "example.com",
    };

    Dispatcher.dispatch(nodes, task);

    std.log.info(
        "distributed hunter grid activated nodes={}",
        .{ nodes.len },
    );
}