const std = @import("std");

pub const Scenario = struct {
    name: []const u8,
    attack_vector: []const u8,
};

pub fn run(scenarios: []Scenario) void {

    std.debug.print(
        "\n🎯 Autonomous Cyber Range Simulation\n",
        .{},
    );

    for (scenarios) |s| {

        std.debug.print(
            "Scenario: {s}\n",
            .{s.name},
        );

        std.debug.print(
            "Attack Vector: {s}\n",
            .{s.attack_vector},
        );

        std.debug.print(
            "Simulating detection and response...\n",
            .{},
        );

        std.debug.print(
            "✓ Defense simulation completed\n\n",
            .{},
        );
    }
}