const std = @import("std");
const Types = @import("darkweb_types.zig");

const DarkWebSignal = Types.DarkWebSignal;

pub const IntelScore = struct {
    signals: u32,
    risk_score: u8,
};

pub fn fuse(signals: []DarkWebSignal) IntelScore {

    var score: u32 = 0;

    for (signals) |s| {
        score += s.confidence;
    }

    const avg =
        if (signals.len == 0) 0
        else score / signals.len;

    const risk: u8 =
        if (avg > 80) 90
        else if (avg > 60) 70
        else 40;

    return IntelScore{
        .signals = @intCast(signals.len),
        .risk_score = risk,
    };
}