const std = @import("std");

pub const AttackEvent = struct {
    step: u8,
    description: []const u8,
};

pub fn replay(events: []AttackEvent) void {

    std.debug.print(
        "\n🎬 Attack Replay Simulator\n",
        .{},
    );

    for (events) |e| {

        std.debug.print(
            "Step {d}: {s}\n",
            .{e.step, e.description},
        );
    }

    std.debug.print(
        "✅ Attack replay completed\n",
        .{},
    );
}