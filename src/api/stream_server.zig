const std = @import("std");

pub fn startStream() void {

    std.log.info(
        "CyberDudeBivash Intel Streaming Engine Online",
        .{},
    );

    std.log.info(
        "Streaming endpoint: /stream/intel",
        .{},
    );
}