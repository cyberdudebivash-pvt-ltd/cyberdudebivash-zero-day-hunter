const std = @import("std");

const controller = @import("controller_api.zig");

pub fn startServer(port: u16) !void {

    const address = try std.net.Address.parseIp("0.0.0.0", port);

    var server = try address.listen(.{});
    defer server.deinit();

    std.debug.print(
        "🌐 CYBERDUDEBIVASH Control API listening on port {d}\n",
        .{port},
    );

    while (true) {

        var conn = try server.accept();
        defer conn.stream.close();

        handleConnection(conn.stream) catch |err| {
            std.debug.print("Connection error: {any}\n", .{err});
        };
    }
}

fn handleConnection(stream: std.net.Stream) !void {

    var buffer: [4096]u8 = undefined;

    const n = try stream.read(&buffer);

    const request = buffer[0..n];

    if (std.mem.indexOf(u8, request, "/node/register")) |_| {

        const node = controller.registerNode("remote-node");

        try respondJSON(
            stream,
            "{\"status\":\"registered\",\"node\":\"node-auto\"}",
        );

        _ = node;
        return;
    }

    if (std.mem.indexOf(u8, request, "/task")) |_| {

        const task = controller.createTask("example.com");

        var buf: [128]u8 = undefined;

        const json = try std.fmt.bufPrint(
            &buf,
            "{{\"task_id\":{},\"target\":\"{s}\"}}",
            .{ task.id, task.target },
        );

        try respondJSON(stream, json);

        return;
    }

    if (std.mem.indexOf(u8, request, "/result")) |_| {

        controller.receiveResults(
            "node-auto",
            "example detection",
        );

        try respondJSON(stream, "{\"status\":\"received\"}");

        return;
    }

    if (std.mem.indexOf(u8, request, "/plugins")) |_| {

        try respondJSON(
            stream,
            "{\"plugins\":[\"rust_malware\",\"ai_model_backdoor\",\"cloud_escape\"]}",
        );

        return;
    }

    try respondJSON(stream, "{\"status\":\"ok\"}");
}

fn respondJSON(stream: std.net.Stream, body: []const u8) !void {

    var buf: [1024]u8 = undefined;

    const response = try std.fmt.bufPrint(
        &buf,
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {}\r\n\r\n{s}",
        .{ body.len, body },
    );

    try stream.writeAll(response);
}