const std = @import("std");

pub const CVE = struct {
    id: []const u8,
    description: []const u8,
    severity: []const u8,
};

pub fn updateFeeds() !void {

    std.debug.print(
        "🌐 CVE Feed Updater starting\n",
        .{},
    );

    try fetchNVDFeed();
    try fetchCISAKev();

    std.debug.print(
        "✅ CVE feeds updated successfully\n",
        .{},
    );
}

fn fetchNVDFeed() !void {

    std.debug.print(
        "📡 Fetching NVD CVE feed\n",
        .{},
    );

    const url = "https://services.nvd.nist.gov/rest/json/cves/2.0";

    try httpFetch(url);
}

fn fetchCISAKev() !void {

    std.debug.print(
        "📡 Fetching CISA Known Exploited Vulnerabilities\n",
        .{},
    );

    const url = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json";

    try httpFetch(url);
}

fn httpFetch(url: []const u8) !void {

    var gpa = std.heap.page_allocator;

    var client = std.http.Client(.{
        .allocator = gpa,
    });

    defer client.deinit();

    var uri = try std.Uri.parse(url);

    var req = try client.request(
        .GET,
        uri,
        .{},
        .{},
    );

    try req.start();
    try req.finish();

    const body = try req.reader().readAllAlloc(
        gpa,
        10 * 1024 * 1024,
    );

    defer gpa.free(body);

    std.debug.print(
        "📥 Feed downloaded ({d} bytes)\n",
        .{body.len},
    );

    try parseFeed(body);
}

fn parseFeed(data: []const u8) !void {

    std.debug.print(
        "🧠 Parsing CVE feed\n",
        .{},
    );

    var parser = std.json.Parser.init(
        std.heap.page_allocator,
        false,
    );

    defer parser.deinit();

    const tree = try parser.parse(data);

    _ = tree;

    std.debug.print(
        "✅ CVE feed parsed\n",
        .{},
    );
}