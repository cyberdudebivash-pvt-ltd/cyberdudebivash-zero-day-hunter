const std = @import("std");

pub fn calculateRisk(
    severity: []const u8,
) u8 {

    if (std.mem.eql(u8, severity, "high"))
        return 9;

    if (std.mem.eql(u8, severity, "medium"))
        return 6;

    return 3;
}