const std = @import("std");

pub const ServiceFingerprint = struct {
    service: []const u8,
    version: []const u8,
};

pub fn fingerprint(ip: []const u8, port: u16) !void {

    std.debug.print(
        "🔎 Banner fingerprinting {s}:{d}\n",
        .{ ip, port },
    );

    var address = try std.net.Address.parseIp(ip, port);

    const timeout_ns: u64 = 3 * std.time.ns_per_s;

    const conn = std.net.tcpConnectToAddress(address, timeout_ns) catch {

        std.debug.print(
            "⚫ Connection failed {s}:{d}\n",
            .{ ip, port },
        );

        return;
    };

    defer conn.close();

    var buffer: [2048]u8 = undefined;

    const bytes = conn.read(&buffer) catch 0;

    if (bytes == 0) {

        std.debug.print(
            "⚫ No banner received {s}:{d}\n",
            .{ ip, port },
        );

        return;
    }

    const banner = buffer[0..bytes];

    std.debug.print(
        "📡 Banner: {s}\n",
        .{banner},
    );

    const service = detectService(banner);

    std.debug.print(
        "🧠 Detected service: {s}\n",
        .{service},
    );
}

fn detectService(banner: []const u8) []const u8 {

    if (std.mem.indexOf(u8, banner, "Apache")) |_| {
        return "Apache HTTP Server";
    }

    if (std.mem.indexOf(u8, banner, "nginx")) |_| {
        return "NGINX";
    }

    if (std.mem.indexOf(u8, banner, "OpenSSH")) |_| {
        return "OpenSSH";
    }

    if (std.mem.indexOf(u8, banner, "Redis")) |_| {
        return "Redis";
    }

    if (std.mem.indexOf(u8, banner, "MongoDB")) |_| {
        return "MongoDB";
    }

    if (std.mem.indexOf(u8, banner, "Elastic")) |_| {
        return "Elasticsearch";
    }

    if (std.mem.indexOf(u8, banner, "Docker")) |_| {
        return "Docker API";
    }

    if (std.mem.indexOf(u8, banner, "Kubernetes")) |_| {
        return "Kubernetes API";
    }

    return "Unknown Service";
}

pub fn fingerprintCommon(ip: []const u8) !void {

    const ports = [_]u16{
        21,
        22,
        25,
        80,
        110,
        143,
        443,
        445,
        6379,
        27017,
        9200,
        2375,
        6443,
    };

    std.debug.print(
        "🌍 Fingerprinting common services on {s}\n",
        .{ip},
    );

    for (ports) |port| {

        fingerprint(ip, port) catch {};
    }
}