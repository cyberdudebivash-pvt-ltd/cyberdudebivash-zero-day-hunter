const std = @import("std");

pub const AttackEvent = struct {
    source_ip: []const u8,
    target_ip: []const u8,
    latitude: f64,
    longitude: f64,
    severity: []const u8,
    timestamp: i64,
};

pub const AttackVisualizer = struct {

    allocator: std.mem.Allocator,
    events: std.ArrayList(AttackEvent),

    pub fn init(allocator: std.mem.Allocator) AttackVisualizer {

        return AttackVisualizer{
            .allocator = allocator,
            .events = std.ArrayList(AttackEvent).init(allocator),
        };
    }

    pub fn deinit(self: *AttackVisualizer) void {
        self.events.deinit();
    }

    /// Add new attack event to visualization stream
    pub fn recordEvent(
        self: *AttackVisualizer,
        source_ip: []const u8,
        target_ip: []const u8,
        lat: f64,
        lon: f64,
        severity: []const u8,
    ) !void {

        const event = AttackEvent{
            .source_ip = source_ip,
            .target_ip = target_ip,
            .latitude = lat,
            .longitude = lon,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        };

        try self.events.append(event);

        std.log.info(
            "🌍 Attack Recorded: {s} → {s}",
            .{ source_ip, target_ip },
        );
    }

    /// Export attack events as JSON
    pub fn exportJson(self: *AttackVisualizer) ![]u8 {

        var buffer = std.ArrayList(u8).init(self.allocator);

        try buffer.appendSlice("{\"attacks\":[");

        for (self.events.items, 0..) |e, i| {

            if (i != 0)
                try buffer.appendSlice(",");

            const entry = try std.fmt.allocPrint(
                self.allocator,
                "{{\"src\":\"{s}\",\"dst\":\"{s}\",\"lat\":{d},\"lon\":{d},\"severity\":\"{s}\",\"ts\":{}}}",
                .{
                    e.source_ip,
                    e.target_ip,
                    e.latitude,
                    e.longitude,
                    e.severity,
                    e.timestamp,
                },
            );

            defer self.allocator.free(entry);

            try buffer.appendSlice(entry);
        }

        try buffer.appendSlice("]}");

        return buffer.toOwnedSlice();
    }

    /// Serve attack visualization API
    pub fn serve(
        self: *AttackVisualizer,
        port: u16,
    ) !void {

        std.log.info(
            "🌐 Global Attack Map API listening on port {}",
            .{port},
        );

        var server = std.net.StreamServer.init(.{
            .reuse_address = true,
        });

        try server.listen(
            try std.net.Address.parseIp("0.0.0.0", port),
        );

        while (true) {

            const conn = try server.accept();
            defer conn.stream.close();

            var buffer: [1024]u8 = undefined;

            const read = try conn.stream.read(&buffer);
            if (read == 0)
                continue;

            const req = buffer[0..read];

            if (std.mem.containsAtLeast(u8, req, 1, "/attacks")) {

                const json = try self.exportJson();
                defer self.allocator.free(json);

                const response = try std.fmt.allocPrint(
                    self.allocator,
                    "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{s}",
                    .{json},
                );

                defer self.allocator.free(response);

                _ = try conn.stream.write(response);

                continue;
            }

            const page =
                \\HTTP/1.1 200 OK
                \\Content-Type: text/html
                \\
                \\<html>
                \\<head>
                \\<title>CYBERDUDEBIVASH Global Attack Map</title>
                \\</head>
                \\<body>
                \\<h1>🌍 Global Cyber Attack Visualization</h1>
                \\<p>API Endpoint:</p>
                \\<ul>
                \\<li>/attacks</li>
                \\</ul>
                \\</body>
                \\</html>
            ;

            _ = try conn.stream.write(page);
        }
    }
};