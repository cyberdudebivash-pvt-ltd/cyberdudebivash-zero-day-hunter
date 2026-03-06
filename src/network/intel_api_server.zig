const std = @import("std");

const DashboardAPI = @import("../command_center/dashboard_api.zig").DashboardAPI;

pub const IntelAPIServer = struct {
    allocator: std.mem.Allocator,
    dashboard: *DashboardAPI,
    port: u16,

    pub fn init(
        allocator: std.mem.Allocator,
        dashboard: *DashboardAPI,
        port: u16,
    ) IntelAPIServer {
        return IntelAPIServer{
            .allocator = allocator,
            .dashboard = dashboard,
            .port = port,
        };
    }

    fn sendResponse(
        stream: std.net.Stream,
        status: []const u8,
        content_type: []const u8,
        body: []const u8,
    ) !void {

        var writer = stream.writer();

        try writer.print(
            "HTTP/1.1 {s}\r\nContent-Type: {s}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{s}",
            .{
                status,
                content_type,
                body.len,
                body,
            },
        );
    }

    fn handleMetrics(self: *IntelAPIServer, stream: std.net.Stream) !void {

        var buffer = std.ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        var writer = buffer.writer();

        try self.dashboard.exportMetricsJSON(writer);

        try sendResponse(
            stream,
            "200 OK",
            "application/json",
            buffer.items,
        );
    }

    fn handleAlerts(self: *IntelAPIServer, stream: std.net.Stream) !void {

        const alerts = self.dashboard.getAlerts();

        var buffer = std.ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        var writer = buffer.writer();

        try writer.print("[", .{});

        for (alerts, 0..) |alert, i| {

            if (i > 0)
                try writer.print(",", .{});

            try writer.print(
                "{{\"id\":{},\"severity\":\"{s}\",\"message\":\"{s}\",\"timestamp\":{}}}",
                .{
                    alert.id,
                    alert.severity,
                    alert.message,
                    alert.timestamp,
                },
            );
        }

        try writer.print("]", .{});

        try sendResponse(
            stream,
            "200 OK",
            "application/json",
            buffer.items,
        );
    }

    fn handleIncidents(self: *IntelAPIServer, stream: std.net.Stream) !void {

        const incidents = self.dashboard.getIncidents();

        var buffer = std.ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        var writer = buffer.writer();

        try writer.print("[", .{});

        for (incidents, 0..) |inc, i| {

            if (i > 0)
                try writer.print(",", .{});

            try writer.print(
                "{{\"id\":{},\"title\":\"{s}\",\"severity\":\"{s}\",\"status\":\"{s}\",\"created\":{}}}",
                .{
                    inc.id,
                    inc.title,
                    inc.severity,
                    inc.status,
                    inc.created_at,
                },
            );
        }

        try writer.print("]", .{});

        try sendResponse(
            stream,
            "200 OK",
            "application/json",
            buffer.items,
        );
    }

    fn handleHealth(stream: std.net.Stream) !void {

        try sendResponse(
            stream,
            "200 OK",
            "application/json",
            "{\"status\":\"ok\"}",
        );
    }

    fn route(self: *IntelAPIServer, path: []const u8, stream: std.net.Stream) !void {

        if (std.mem.eql(u8, path, "/api/metrics")) {
            return self.handleMetrics(stream);
        }

        if (std.mem.eql(u8, path, "/api/alerts")) {
            return self.handleAlerts(stream);
        }

        if (std.mem.eql(u8, path, "/api/incidents")) {
            return self.handleIncidents(stream);
        }

        if (std.mem.eql(u8, path, "/health")) {
            return handleHealth(stream);
        }

        try sendResponse(
            stream,
            "404 Not Found",
            "text/plain",
            "Not Found",
        );
    }

    fn parsePath(request: []const u8) []const u8 {

        const first_space = std.mem.indexOfScalar(u8, request, ' ') orelse return "/";

        const rest = request[first_space + 1 ..];

        const second_space = std.mem.indexOfScalar(u8, rest, ' ') orelse return "/";

        return rest[0..second_space];
    }

    pub fn start(self: *IntelAPIServer) !void {

        var server = std.net.StreamServer.init(.{});
        defer server.deinit();

        try server.listen(
            try std.net.Address.parseIp("0.0.0.0", self.port),
        );

        std.debug.print(
            "CYBERDUDEBIVASH Intel API Server listening on port {d}\n",
            .{self.port},
        );

        while (true) {

            var conn = try server.accept();
            defer conn.stream.close();

            var buf: [4096]u8 = undefined;

            const n = try conn.stream.read(&buf);

            const request = buf[0..n];

            const path = parsePath(request);

            try self.route(path, conn.stream);
        }
    }
};