const std = @import("std");

pub const Telemetry = struct {
    process_name: []const u8,
    network_activity: []const u8,
};

pub fn hunt(data: []Telemetry) void {

    std.debug.print(
        "\n🤖 AI Threat Hunting Engine\n",
        .{},
    );

    for (data) |t| {

        std.debug.print(
            "Analyzing process: {s}\n",
            .{t.process_name},
        );

        if (std.mem.containsAtLeast(u8, t.process_name, 1, "mimikatz")) {

            std.debug.print(
                "⚠ Credential dumping activity detected\n",
                .{},
            );

        } else if (std.mem.containsAtLeast(u8, t.network_activity, 1, "tor")) {

            std.debug.print(
                "⚠ Suspicious TOR communication\n",
                .{},
            );

        } else {

            std.debug.print(
                "✓ No anomaly detected\n",
                .{},
            );
        }
    }
}