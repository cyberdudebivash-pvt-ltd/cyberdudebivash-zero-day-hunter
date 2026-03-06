const std = @import("std");

pub const DefenseAction = struct {
    target_ip: []const u8,
    action: []const u8,
};

pub fn execute(action: DefenseAction) void {

    std.debug.print(
        "\n🛡 Autonomous Defense Orchestrator\n",
        .{},
    );

    std.debug.print(
        "Target: {s}\n",
        .{action.target_ip},
    );

    std.debug.print(
        "Action: {s}\n",
        .{action.action},
    );

    if (std.mem.eql(u8, action.action, "block")) {

        firewallBlock(action.target_ip);

    } else if (std.mem.eql(u8, action.action, "isolate")) {

        isolateHost(action.target_ip);

    } else {

        std.debug.print(
            "ℹ Monitoring action executed\n",
            .{},
        );
    }
}

fn firewallBlock(ip: []const u8) void {

    std.debug.print(
        "🔥 Firewall blocking IP: {s}\n",
        .{ip},
    );
}

fn isolateHost(ip: []const u8) void {

    std.debug.print(
        "🔒 Isolating compromised host: {s}\n",
        .{ip},
    );
}