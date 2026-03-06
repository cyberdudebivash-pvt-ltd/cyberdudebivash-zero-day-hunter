const std = @import("std");

pub fn fetchTask(node_id: []const u8) ![]const u8 {

    _ = node_id;

    std.debug.print(
        "📥 Fetching scan task...\n",
        .{},
    );

    // Example target
    return "example.com";
}