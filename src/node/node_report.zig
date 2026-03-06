const std = @import("std");

pub fn submitResults(node_id: []const u8) !void {

    std.debug.print(
        "📤 Uploading findings for node {s}\n",
        .{node_id},
    );

    std.debug.print(
        "🛰 Syncing with intel.cyberdudebivash.com\n",
        .{},
    );
}