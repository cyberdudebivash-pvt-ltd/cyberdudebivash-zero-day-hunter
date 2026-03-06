const std = @import("std");

pub fn assessThreat(
    campaign: []const u8,
) u8 {

    if (std.mem.indexOf(u8, campaign, "Harvest") != null)
        return 9;

    return 5;
}