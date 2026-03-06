const std = @import("std");
const Types = @import("strategy_types.zig");

const DefenseStrategy = Types.DefenseStrategy;

pub fn generate(
    allocator: std.mem.Allocator,
    risk_level: u8,
) ![]DefenseStrategy {

    var list = std.ArrayList(DefenseStrategy).init(allocator);

    if (risk_level > 80) {

        try list.append(.{
            .strategy = "activate_network_isolation_protocol",
            .priority = 90,
        });

        try list.append(.{
            .strategy = "enable_global_ioc_blocking",
            .priority = 85,
        });
    } else if (risk_level > 60) {

        try list.append(.{
            .strategy = "increase_monitoring_thresholds",
            .priority = 70,
        });

        try list.append(.{
            .strategy = "deploy_patch_updates",
            .priority = 65,
        });
    } else {

        try list.append(.{
            .strategy = "maintain_standard_monitoring",
            .priority = 40,
        });
    }

    return list.toOwnedSlice();
}