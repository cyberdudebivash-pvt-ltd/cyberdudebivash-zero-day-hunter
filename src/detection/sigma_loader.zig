const std = @import("std");

pub const SigmaRule = struct {
    title: []const u8,
    detection: []const u8,
    severity: []const u8,
};

pub fn loadSigma(
    allocator: std.mem.Allocator,
) ![]SigmaRule {

    var rules = std.ArrayList(SigmaRule).init(allocator);

    var dir = try std.fs.cwd().openDir("sigma", .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();

    while (try it.next()) |entry| {

        if (entry.kind != .file)
            continue;

        const path = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{"sigma/", entry.name},
        );

        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const data = try file.readToEndAlloc(allocator, 4096);

        try rules.append(.{
            .title = entry.name,
            .detection = data,
            .severity = "medium",
        });
    }

    return rules.toOwnedSlice();
}