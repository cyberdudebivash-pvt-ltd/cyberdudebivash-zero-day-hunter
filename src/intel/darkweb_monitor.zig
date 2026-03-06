const std = @import("std");

pub const DarkwebSignal = struct {
    forum: []const u8,
    indicator: []const u8,
    mentions: usize,
};

pub fn analyze(signals: []const DarkwebSignal) void {

    std.debug.print(
        "\n🕶 Darkweb Intelligence Monitor\n",
        .{},
    );

    for (signals) |s| {

        std.debug.print(
            "\n🔎 Forum: {s}\n",
            .{s.forum},
        );

        std.debug.print(
            "Indicator: {s}\n",
            .{s.indicator},
        );

        std.debug.print(
            "Mentions: {d}\n",
            .{s.mentions},
        );

        if (s.mentions > 5) {

            std.debug.print(
                "🚨 Elevated underground activity detected\n",
                .{},
            );
        }
    }
}