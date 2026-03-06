const std = @import("std");
const Types = @import("darkweb_types.zig");

const DarkWebSignal = Types.DarkWebSignal;

pub fn ingest(
    allocator: std.mem.Allocator,
) ![]DarkWebSignal {

    var list = std.ArrayList(DarkWebSignal).init(allocator);

    // placeholder ingest example

    try list.append(.{
        .source = "forum_feed",
        .category = "exploit_discussion",
        .indicator = "CVE-2026-XXXX",
        .confidence = 70,
    });

    return list.toOwnedSlice();
}