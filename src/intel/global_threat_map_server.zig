const std = @import("std");

pub const AttackEvent = struct {
    source_ip: []const u8,
    target_ip: []const u8,
    malware: []const u8,
    country: []const u8,
};

pub fn startServer() !void {

    const allocator = std.heap.page_allocator;

    var server = std.net.StreamServer.init(.{
        .reuse_address = true,
    });

    const address = try std.net.Address.parseIp("0.0.0.0", 8081);

    try server.listen(address);

    std.debug.print(
        "\n🌍 CyberDudeBivash Global Threat Map Server started\n",
        .{},
    );

    std.debug.print(
        "Listening on http://0.0.0.0:8081\n",
        .{},
    );

    while (true) {

        var connection = try server.accept();

        defer connection.stream.close();

        handleClient(connection.stream, allocator) catch {};
    }
}

fn handleClient(
    stream: std.net.Stream,
    allocator: std.mem.Allocator,
) !void {

    var buffer: [1024]u8 = undefined;

    _ = try stream.read(&buffer);

    const response =
        "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: application/json\r\n\r\n" ++
        attackJSON();

    try stream.writeAll(response);
}

fn attackJSON() []const u8 {

    return
        "{"
        "\"attacks\": ["
        "{"
        "\"source\": \"185.193.127.10\","
        "\"target\": \"192.168.1.10\","
        "\"country\": \"RU\","
        "\"malware\": \"Mirai\""
        "},"
        "{"
        "\"source\": \"91.214.124.55\","
        "\"target\": \"192.168.1.22\","
        "\"country\": \"CN\","
        "\"malware\": \"Emotet\""
        "}"
        "]"
        "}";
}