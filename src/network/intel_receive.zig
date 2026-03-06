const std = @import("std");

pub fn pullIntel(
    allocator: std.mem.Allocator,
) !void {

    const client = std.http.Client{ .allocator = allocator };

    var req = try client.open(
        .GET,
        "https://intel.cyberdudebivash.com/api/feed",
        .{},
        .{},
    );

    defer req.deinit();

    try req.send();
    try req.wait();

    std.log.info(
        "Received CyberDudeBivash global intel feed",
        .{},
    );
}