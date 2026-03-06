const std = @import("std");

pub const Severity = enum {
    low,
    medium,
    high,
    critical,
};

pub const Vulnerability = struct {
    service: []const u8,
    indicator: []const u8,
    cve: []const u8,
    severity: Severity,
    description: []const u8,
};

pub fn analyze(service: []const u8, banner: []const u8) void {

    std.debug.print(
        "🧠 Vulnerability matcher analyzing service: {s}\n",
        .{service},
    );

    const db = vulnerabilityDB();

    for (db) |v| {

        if (!std.mem.eql(u8, v.service, service))
            continue;

        if (std.mem.indexOf(u8, banner, v.indicator)) |_| {

            reportVulnerability(v);
        }
    }
}

fn reportVulnerability(v: Vulnerability) void {

    std.debug.print(
        "\n🚨 Vulnerability detected!\n",
        .{},
    );

    std.debug.print(
        "Service: {s}\n",
        .{v.service},
    );

    std.debug.print(
        "Indicator: {s}\n",
        .{v.indicator},
    );

    std.debug.print(
        "CVE: {s}\n",
        .{v.cve},
    );

    std.debug.print(
        "Severity: {s}\n",
        .{severityToString(v.severity)},
    );

    std.debug.print(
        "Description: {s}\n\n",
        .{v.description},
    );
}

fn severityToString(s: Severity) []const u8 {

    return switch (s) {
        .low => "LOW",
        .medium => "MEDIUM",
        .high => "HIGH",
        .critical => "CRITICAL",
    };
}

fn vulnerabilityDB() []const Vulnerability {

    return &[_]Vulnerability{

        .{
            .service = "Apache HTTP Server",
            .indicator = "Apache/2.4.49",
            .cve = "CVE-2021-41773",
            .severity = .critical,
            .description = "Apache path traversal leading to remote code execution",
        },

        .{
            .service = "OpenSSH",
            .indicator = "OpenSSH_7.2",
            .cve = "CVE-2016-0777",
            .severity = .high,
            .description = "OpenSSH information disclosure vulnerability",
        },

        .{
            .service = "Redis",
            .indicator = "Redis",
            .cve = "Unauthenticated Redis Exposure",
            .severity = .critical,
            .description = "Redis instance exposed without authentication",
        },

        .{
            .service = "MongoDB",
            .indicator = "MongoDB",
            .cve = "MongoDB Open Database",
            .severity = .critical,
            .description = "MongoDB database accessible without credentials",
        },

        .{
            .service = "Elasticsearch",
            .indicator = "Elastic",
            .cve = "Open Elasticsearch Cluster",
            .severity = .high,
            .description = "Public Elasticsearch cluster detected",
        },

        .{
            .service = "Docker API",
            .indicator = "Docker",
            .cve = "Docker Remote API Exposure",
            .severity = .critical,
            .description = "Docker daemon accessible remotely",
        },

        .{
            .service = "Kubernetes API",
            .indicator = "Kubernetes",
            .cve = "Kubernetes Control Plane Exposure",
            .severity = .critical,
            .description = "Public Kubernetes API detected",
        },
    };
}