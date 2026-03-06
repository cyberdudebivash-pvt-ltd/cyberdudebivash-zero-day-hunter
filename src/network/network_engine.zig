const std = @import("std");

const IntelEvent = @import("intel_event.zig").IntelEvent;
const Share = @import("intel_share.zig");
const Receive = @import("intel_receive.zig");

pub fn processIntel(
    allocator: std.mem.Allocator,
    event: IntelEvent,
) !void {

    try Share.shareEvent(allocator, event);

    try Receive.pullIntel(allocator);
}