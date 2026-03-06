const std = @import("std");

pub fn trackCampaign(
    campaign: []const u8,
) void {

    std.log.info(
        "Active Threat Campaign: {s}",
        .{campaign},
    );
}