const std = @import("std");

pub fn start() !void {

    var server = std.net.StreamServer.init(.{
        .reuse_address = true,
    });

    const address = try std.net.Address.parseIp("0.0.0.0", 8082);

    try server.listen(address);

    std.debug.print(
        "\n🛰 Sentinel APEX Dashboard API started\n",
        .{},
    );

    std.debug.print(
        "Listening on http://0.0.0.0:8082\n",
        .{},
    );

    while (true) {

        var connection = try server.accept();
        defer connection.stream.close();

        handleRequest(connection.stream) catch {};
    }
}

fn handleRequest(stream: std.net.Stream) !void {

    var buffer: [1024]u8 = undefined;

    const len = try stream.read(&buffer);

    const request = buffer[0..len];

    if (std.mem.containsAtLeast(u8, request, 1, "/intel/feed")) {

        try respond(stream, feed());

    } else if (std.mem.containsAtLeast(u8, request, 1, "/intel/cve")) {

        try respond(stream, cve());

    } else if (std.mem.containsAtLeast(u8, request, 1, "/intel/botnets")) {

        try respond(stream, botnets());

    } else if (std.mem.containsAtLeast(u8, request, 1, "/intel/heatmap")) {

        try respond(stream, heatmap());

    } else if (std.mem.containsAtLeast(u8, request, 1, "/intel/predictions")) {

        try respond(stream, predictions());

    } else {

        try respond(stream, "{\"status\":\"sentinel-online\"}");
    }
}

fn respond(stream: std.net.Stream, body: []const u8) !void {

    const header =
        "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: application/json\r\n\r\n";

    try stream.writeAll(header);
    try stream.writeAll(body);
}

fn feed() []const u8 {

    return
        "{"
        "\"alerts\": ["
        "{ \"indicator\": \"CVE-2021-41773\", \"severity\": \"critical\" },"
        "{ \"indicator\": \"Mirai Botnet\", \"severity\": \"high\" }"
        "]"
        "}";
}

fn cve() []const u8 {

    return
        "{"
        "\"cve\": ["
        "{ \"id\": \"CVE-2021-41773\", \"score\": 9.8 },"
        "{ \"id\": \"CVE-2023-23397\", \"score\": 9.0 }"
        "]"
        "}";
}

fn botnets() []const u8 {

    return
        "{"
        "\"botnets\": ["
        "{ \"name\": \"Mirai\", \"nodes\": 18231 },"
        "{ \"name\": \"Emotet\", \"nodes\": 5412 }"
        "]"
        "}";
}

fn heatmap() []const u8 {

    return
        "{"
        "\"regions\": ["
        "{ \"country\": \"CN\", \"attacks\": 120 },"
        "{ \"country\": \"RU\", \"attacks\": 87 },"
        "{ \"country\": \"BR\", \"attacks\": 41 }"
        "]"
        "}";
}

fn predictions() []const u8 {

    return
        "{"
        "\"predictions\": ["
        "{ \"target\": \"Apache HTTP Server\", \"risk\": 0.87 },"
        "{ \"target\": \"Docker Remote API\", \"risk\": 0.63 }"
        "]"
        "}";
}