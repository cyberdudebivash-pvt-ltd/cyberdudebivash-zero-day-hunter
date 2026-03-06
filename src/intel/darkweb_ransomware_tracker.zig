const std = @import("std");
const Types = @import("darkweb_types.zig");

const RansomwareSignal = Types.RansomwareSignal;

pub fn detect_activity(
    allocator: std.mem.Allocator,
    signals: []RansomwareSignal,
) !u32 {

    var victims: u32 = 0;

    for (signals) |_| {
        victims += 1;
    }

    return victims;
}