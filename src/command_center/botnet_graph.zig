const std = @import("std");

pub fn renderBotnetGraph(
    botnet: []const u8,
) void {

    std.log.info(
        "Botnet Infrastructure Graph: {s}",
        .{botnet},
    );
}