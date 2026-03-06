const std = @import("std");

const FeedEntry = @import("feed_manifest.zig").FeedEntry;
const Sync = @import("rule_sync.zig");

pub fn updateFeeds(
    allocator: std.mem.Allocator,
) !void {

    const feeds = [_]FeedEntry{

        .{
            .name = "sigma_pack",
            .url = "https://intel.cyberdudebivash.com/sigma_pack.zip",
            .category = "sigma",
        },

        .{
            .name = "yara_pack",
            .url = "https://intel.cyberdudebivash.com/yara_pack.zip",
            .category = "yara",
        },

        .{
            .name = "exploit_rules",
            .url = "https://intel.cyberdudebivash.com/exploit_rules.zip",
            .category = "rules",
        },
    };

    for (feeds) |feed| {

        std.log.info(
            "Downloading CyberDudeBivash intel feed: {s}",
            .{feed.name},
        );

        const path = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{"intel/", feed.name},
        );

        try Sync.downloadRule(
            allocator,
            feed.url,
            path,
        );
    }

    std.log.info(
        "CyberDudeBivash Threat Intel feeds updated",
        .{},
    );
}