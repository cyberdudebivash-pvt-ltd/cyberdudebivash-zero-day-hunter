const std = @import("std");

pub fn showPrediction(
    campaign: []const u8,
) void {

    std.log.warn(
        "Predicted Attack Campaign: {s}",
        .{campaign},
    );
}