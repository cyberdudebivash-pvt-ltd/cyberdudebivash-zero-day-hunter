const std = @import("std");

const Collector = @import("command_center_collector.zig");
const State = @import("command_center_state.zig");
const Dashboard = @import("command_center_dashboard.zig");

pub fn run(
    allocator: std.mem.Allocator,
) !void {

    const metrics = try Collector.collect(allocator);

    const state = try State.build_state(allocator, metrics);

    Dashboard.render(state);
}