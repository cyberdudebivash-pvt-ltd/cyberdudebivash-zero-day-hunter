const std = @import("std");

pub fn deployRule(
    rule_name: []const u8,
) void {

    std.log.info(
        "Deploying new detection rule globally: {s}",
        .{rule_name},
    );

    // future integration
    // rule repository
    // distributed nodes
}