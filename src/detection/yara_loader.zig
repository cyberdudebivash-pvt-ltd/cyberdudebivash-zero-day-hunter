const std = @import("std");

pub const YaraRule = struct {
    name: []const u8,
    pattern: []const u8,
};

pub fn loadYara(
    allocator: std.mem.Allocator,
) ![]YaraRule {

    var rules = std.ArrayList(YaraRule).init(allocator);

    var dir = try std.fs.cwd().openDir("yara", .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();

    while (try it.next()) |entry| {

        if (entry.kind != .file)
            continue;

        const path = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{"yara/", entry.name},
        );

        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const data = try file.readToEndAlloc(allocator, 4096);

        try rules.append(.{
            .name = entry.name,
            .pattern = data,
        });
    }

    return rules.toOwnedSlice();
}