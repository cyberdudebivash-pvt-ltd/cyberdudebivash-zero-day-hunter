const std = @import("std");

pub const SOCStats = struct {
    active_nodes: usize,
    active_threats: usize,
    blocked_ips: usize,
};

pub fn show(stats: SOCStats) void {

    std.debug.print(
        "\n🛡 CYBERDUDEBIVASH SOC COMMAND CENTER\n",
        .{},
    );

    std.debug.print(
        "Active Hunter Nodes: {d}\n",
        .{stats.active_nodes},
    );

    std.debug.print(
        "Active Threats Detected: {d}\n",
        .{stats.active_threats},
    );

    std.debug.print(
        "Blocked IPs: {d}\n",
        .{stats.blocked_ips},
    );

    std.debug.print(
        "SOC Status: OPERATIONAL\n",
        .{},
    );
}