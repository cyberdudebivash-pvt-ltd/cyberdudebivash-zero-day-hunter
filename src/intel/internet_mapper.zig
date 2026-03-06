const std = @import("std");

pub fn scanHost(host: []const u8) !void {

    std.debug.print(
        "🌍 Internet Mapper scanning host: {s}\n",
        .{host},
    );

    const ports = [_]u16{
        21, 22, 25, 53, 80, 110, 143, 443,
        445, 3389, 8080, 8443,
    };

    for (ports) |p| {
        try scanPort(host, p);
    }

    std.debug.print(
        "🛰 Host scan complete\n",
        .{},
    );
}

fn scanPort(host: []const u8, port: u16) !void {

    std.debug.print(
        "🔎 Probing {s}:{d}\n",
        .{host, port},
    );

    const addr = try std.net.Address.resolveIp(host, port);

    var socket = std.net.tcpConnectToAddress(addr) catch {
        return;
    };

    defer socket.close();

    std.debug.print(
        "🟢 Port OPEN → {s}:{d}\n",
        .{host, port},
    );
}

pub fn scanRange(base_ip: []const u8) !void {

    std.debug.print(
        "🌐 Mapping subnet: {s}\n",
        .{base_ip},
    );

    var i: u8 = 1;

    while (i < 10) : (i += 1) {

        var buf: [64]u8 = undefined;

        const ip = try std.fmt.bufPrint(
            &buf,
            "{s}.{d}",
            .{base_ip, i},
        );

        scanHost(ip) catch {};
    }

    std.debug.print(
        "🌍 Network mapping complete\n",
        .{},
    );
}