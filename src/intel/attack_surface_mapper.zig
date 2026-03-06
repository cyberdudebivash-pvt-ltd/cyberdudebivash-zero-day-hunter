const std = @import("std");

pub const AssetType = enum {
    subdomain,
    ip,
    cloud,
};

pub const Asset = struct {
    asset_type: AssetType,
    value: []const u8,
};

pub const SurfaceMap = struct {
    organization: []const u8,
    assets: std.ArrayList(Asset),
};

pub fn mapDomain(allocator: std.mem.Allocator, domain: []const u8) !SurfaceMap {

    std.debug.print(
        "🛰 CyberDudeBivash Attack Surface Mapping for {s}\n",
        .{domain},
    );

    var surface = SurfaceMap{
        .organization = domain,
        .assets = std.ArrayList(Asset).init(allocator),
    };

    try enumerateSubdomains(&surface, domain);
    try resolveIPs(&surface, domain);
    try detectCloudAssets(&surface, domain);

    return surface;
}

fn enumerateSubdomains(surface: *SurfaceMap, domain: []const u8) !void {

    std.debug.print(
        "🔎 Subdomain enumeration\n",
        .{},
    );

    const common = [_][]const u8{
        "www",
        "api",
        "dev",
        "stage",
        "admin",
        "mail",
        "vpn",
    };

    for (common) |sub| {

        var buf: [256]u8 = undefined;

        const host = try std.fmt.bufPrint(
            &buf,
            "{s}.{s}",
            .{ sub, domain },
        );

        std.debug.print(
            "🌐 Subdomain discovered: {s}\n",
            .{host},
        );

        try surface.assets.append(.{
            .asset_type = .subdomain,
            .value = try std.heap.page_allocator.dupe(u8, host),
        });
    }
}

fn resolveIPs(surface: *SurfaceMap, domain: []const u8) !void {

    std.debug.print(
        "🌍 DNS resolution\n",
        .{},
    );

    var list = try std.net.getAddressList(
        std.heap.page_allocator,
        domain,
        80,
    );

    defer list.deinit();

    for (list.addrs) |addr| {

        var buf: [64]u8 = undefined;

        const ip = try addr.format(&buf);

        std.debug.print(
            "🖧 IP discovered: {s}\n",
            .{ip},
        );

        try surface.assets.append(.{
            .asset_type = .ip,
            .value = try std.heap.page_allocator.dupe(u8, ip),
        });
    }
}

fn detectCloudAssets(surface: *SurfaceMap, domain: []const u8) !void {

    std.debug.print(
        "☁️ Cloud asset discovery\n",
        .{},
    );

    const patterns = [_][]const u8{
        "s3.amazonaws.com",
        "blob.core.windows.net",
        "storage.googleapis.com",
    };

    for (patterns) |p| {

        var buf: [256]u8 = undefined;

        const cloud = try std.fmt.bufPrint(
            &buf,
            "{s}.{s}",
            .{ domain, p },
        );

        std.debug.print(
            "🔍 Cloud pattern detected: {s}\n",
            .{cloud},
        );

        try surface.assets.append(.{
            .asset_type = .cloud,
            .value = try std.heap.page_allocator.dupe(u8, cloud),
        });
    }
}