const std = @import("std");

pub fn startAPI() void {

    std.log.info(
        "CyberDudeBivash Threat Intelligence API started",
        .{},
    );

    std.log.info(
        "Endpoint: /api/intel",
        .{},
    );

    std.log.info(
        "Endpoint: /api/campaigns",
        .{},
    );
}