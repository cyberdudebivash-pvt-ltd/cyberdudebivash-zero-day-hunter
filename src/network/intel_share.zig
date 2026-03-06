const std = @import("std");

const IntelEvent = @import("intel_event.zig").IntelEvent;

pub fn shareEvent(
    allocator: std.mem.Allocator,
    event: IntelEvent,
) !void {

    const client = std.http.Client{ .allocator = allocator };

    var req = try client.open(
        .POST,
        "https://intel.cyberdudebivash.com/api/intel",
        .{},
        .{},
    );

    defer req.deinit();

    try req.send();
    try req.writeAll(event.description);
    try req.finish();

    std.log.info(
        "Intel event shared with CyberDudeBivash network",
        .{},
    );
}