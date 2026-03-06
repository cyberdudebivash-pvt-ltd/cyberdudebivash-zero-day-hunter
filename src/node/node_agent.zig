const std = @import("std");

const register = @import("node_register.zig");
const tasks = @import("node_tasks.zig");
const report = @import("node_report.zig");

const engine = @import("../core/engine.zig");

pub fn startNode() !void {

    std.debug.print(
        "\n🌐 CYBERDUDEBIVASH Distributed Hunter Node\n",
        .{},
    );

    const node_id = try register.registerNode();

    std.debug.print(
        "🛰 Node registered: {s}\n",
        .{node_id},
    );

    while (true) {

        const task = try tasks.fetchTask(node_id);

        std.debug.print(
            "\n🎯 Assigned target: {s}\n",
            .{task},
        );

        try engine.runHunters();

        try report.submitResults(node_id);

        std.time.sleep(5 * std.time.ns_per_s);
    }
}