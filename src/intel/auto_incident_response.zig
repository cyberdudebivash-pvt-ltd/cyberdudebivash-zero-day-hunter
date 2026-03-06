const std = @import("std");

pub const Incident = struct {
    source_ip: []const u8,
    threat_type: []const u8,
    severity: u8,
};

pub fn respond(incident: Incident) void {

    std.debug.print(
        "\n🚨 Autonomous Incident Response Triggered\n",
        .{},
    );

    std.debug.print(
        "Threat Type: {s}\n",
        .{incident.threat_type},
    );

    std.debug.print(
        "Source IP: {s}\n",
        .{incident.source_ip},
    );

    if (incident.severity >= 9) {

        blockIP(incident.source_ip);
        isolateHost();

    } else if (incident.severity >= 7) {

        blockIP(incident.source_ip);

    } else {

        std.debug.print(
            "ℹ Monitoring threat activity\n",
            .{},
        );
    }
}

fn blockIP(ip: []const u8) void {

    std.debug.print(
        "🔥 Firewall rule added to block {s}\n",
        .{ip},
    );
}

fn isolateHost() void {

    std.debug.print(
        "🔒 Host isolation triggered\n",
        .{},
    );
}