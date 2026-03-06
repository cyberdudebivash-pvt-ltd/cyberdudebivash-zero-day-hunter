const std = @import("std");
const Types = @import("command_center_types.zig");

const CommandMetric = Types.CommandMetric;

pub fn collect(
    allocator: std.mem.Allocator,
) ![]CommandMetric {

    var metrics = std.ArrayList(CommandMetric).init(allocator);

    try metrics.append(.{
        .name = "active_threat_signals",
        .value = 42,
    });

    try metrics.append(.{
        .name = "botnet_nodes_detected",
        .value = 12,
    });

    try metrics.append(.{
        .name = "campaigns_detected",
        .value = 5,
    });

    try metrics.append(.{
        .name = "predicted_attack_waves",
        .value = 3,
    });

    return metrics.toOwnedSlice();
}