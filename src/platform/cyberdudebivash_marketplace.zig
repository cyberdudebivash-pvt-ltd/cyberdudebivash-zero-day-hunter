const std = @import("std");

pub const MarketplaceItem = struct {
    name: []const u8,
    author: []const u8,
    category: []const u8,
};

var allocator = std.heap.page_allocator;
var catalog = std.ArrayList(MarketplaceItem).init(allocator);

pub fn publish(name: []const u8, author: []const u8, category: []const u8) !void {

    try catalog.append(.{
        .name = name,
        .author = author,
        .category = category,
    });

    std.debug.print(
        "🛒 Marketplace item published: {s} by {s}\n",
        .{ name, author },
    );
}

pub fn list() void {

    std.debug.print(
        "\n📦 CyberDudeBivash Marketplace\n",
        .{},
    );

    for (catalog.items) |item| {

        std.debug.print(
            "Tool: {s} | Author: {s} | Category: {s}\n",
            .{ item.name, item.author, item.category },
        );
    }
}