const std = @import("std");

pub fn downloadRule(
    allocator: std.mem.Allocator,
    url: []const u8,
    path: []const u8,
) !void {

    const client = std.http.Client{ .allocator = allocator };
    var request = try client.open(.GET, url, .{}, .{});
    defer request.deinit();

    try request.send();
    try request.wait();

    const body = try request.reader().readAllAlloc(allocator, 65536);

    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    try file.writeAll(body);
}