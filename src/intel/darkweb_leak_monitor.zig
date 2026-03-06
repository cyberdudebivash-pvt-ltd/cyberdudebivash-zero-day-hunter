const std = @import("std");
const Types = @import("darkweb_types.zig");

const LeakRecord = Types.LeakRecord;

pub fn analyze_leaks(
    allocator: std.mem.Allocator,
    leaks: []LeakRecord,
) !u32 {

    var affected: u32 = 0;

    for (leaks) |_| {
        affected += 1;
    }

    return affected;
}