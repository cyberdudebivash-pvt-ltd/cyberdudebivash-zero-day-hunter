const std = @import("std");

const HealthMonitor =
    @import("../core/health_monitor.zig").HealthMonitor;

pub const DashboardServer = struct {

    allocator: std.mem.Allocator,
    port: u16,
    health_monitor: *HealthMonitor,

    pub fn init(
        allocator: std.mem.Allocator,
        port: u16,
        monitor: *HealthMonitor,
    ) DashboardServer {

        return DashboardServer{
            .allocator = allocator,
            .port = port,
            .health_monitor = monitor,
        };
    }

    pub fn start(self: *DashboardServer) !void {

        std.log.info(
            "🛰️ Starting SOC Dashboard Server on port {}",
            .{self.port},
        );

        var server = std.net.StreamServer.init(.{
            .reuse_address = true,
        });

        try server.listen(
            try std.net.Address.parseIp("0.0.0.0", self.port),
        );

        while (true) {

            const conn = try server.accept();
            defer conn.stream.close();

            try self.handleConnection(conn.stream);
        }
    }

    fn handleConnection(
        self: *DashboardServer,
        stream: std.net.Stream,
    ) !void {

        var buffer: [2048]u8 = undefined;

        const read = try stream.read(&buffer);

        if (read == 0)
            return;

        const request = buffer[0..read];

        if (std.mem.containsAtLeast(u8, request, 1, "/health")) {

            try self.sendHealth(stream);
            return;
        }

        if (std.mem.containsAtLeast(u8, request, 1, "/status")) {

            try self.sendStatus(stream);
            return;
        }

        try self.sendRoot(stream);
    }

    fn sendRoot(
        self: *DashboardServer,
        stream: std.net.Stream,
    ) !void {

        const html =
            \\HTTP/1.1 200 OK
            \\Content-Type: text/html
            \\
            \\<html>
            \\<head>
            \\<title>CYBERDUDEBIVASH SOC Dashboard</title>
            \\</head>
            \\<body>
            \\<h1>🛰 CYBERDUDEBIVASH SOC COMMAND CENTER</h1>
            \\<p>Platform Status: ACTIVE</p>
            \\<p>Endpoints:</p>
            \\<ul>
            \\<li>/health</li>
            \\<li>/status</li>
            \\</ul>
            \\</body>
            \\</html>
        ;

        _ = try stream.write(html);
    }

    fn sendHealth(
        self: *DashboardServer,
        stream: std.net.Stream,
    ) !void {

        const h = self.health_monitor.last_health;

        const json = try std.fmt.allocPrint(
            self.allocator,
            \\HTTP/1.1 200 OK
            \\Content-Type: application/json
            \\
            \\{{"threads":{}, "tasks":{}, "memory":{}, "cpu":{d:.2}, "uptime":{}}}
        ,
            .{
                h.active_threads,
                h.active_tasks,
                h.allocated_memory,
                h.cpu_usage_percent,
                h.uptime_seconds,
            },
        );

        defer self.allocator.free(json);

        _ = try stream.write(json);
    }

    fn sendStatus(
        self: *DashboardServer,
        stream: std.net.Stream,
    ) !void {

        const json =
            \\HTTP/1.1 200 OK
            \\Content-Type: application/json
            \\
            \\{"platform":"CYBERDUDEBIVASH",
            \\ "mode":"SOC",
            \\ "status":"operational",
            \\ "engine":"autonomous-cyber-defense"}
        ;

        _ = try stream.write(json);
    }
};