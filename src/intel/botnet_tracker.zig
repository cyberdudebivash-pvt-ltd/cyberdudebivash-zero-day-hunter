const std = @import("std");

pub const Botnet = struct {
    name: []const u8,
    malware_family: []const u8,
    c2_server: []const u8,
    attack_type: []const u8,
    description: []const u8,
};

pub const BotnetObservation = struct {
    infected_ip: []const u8,
    botnet: Botnet,
};

pub fn analyze(ip: []const u8, malware: []const u8) void {

    std.debug.print(
        "🕸 Botnet activity analysis for {s}\n",
        .{ip},
    );

    const db = botnetDB();

    for (db) |b| {

        if (std.mem.eql(u8, b.malware_family, malware)) {

            reportBotnet(ip, b);
            return;
        }
    }

    std.debug.print(
        "ℹ️ No botnet correlation detected\n",
        .{},
    );
}

fn reportBotnet(ip: []const u8, b: Botnet) void {

    std.debug.print(
        "\n🚨 Botnet Activity Detected\n",
        .{},
    );

    std.debug.print(
        "Infected Host: {s}\n",
        .{ip},
    );

    std.debug.print(
        "Botnet: {s}\n",
        .{b.name},
    );

    std.debug.print(
        "Malware Family: {s}\n",
        .{b.malware_family},
    );

    std.debug.print(
        "C2 Server: {s}\n",
        .{b.c2_server},
    );

    std.debug.print(
        "Attack Type: {s}\n",
        .{b.attack_type},
    );

    std.debug.print(
        "Description: {s}\n\n",
        .{b.description},
    );
}

fn botnetDB() []const Botnet {

    return &[_]Botnet{

        .{
            .name = "Mirai Global Botnet",
            .malware_family = "Mirai Variant",
            .c2_server = "185.193.127.10",
            .attack_type = "DDoS",
            .description =
                "Large-scale IoT botnet targeting routers and cameras.",
        },

        .{
            .name = "Mozi P2P Botnet",
            .malware_family = "Mozi",
            .c2_server = "P2P Distributed",
            .attack_type = "DDoS / Network Scanning",
            .description =
                "Peer-to-peer IoT botnet exploiting weak credentials.",
        },

        .{
            .name = "TrickBot Botnet",
            .malware_family = "TrickBot",
            .c2_server = "45.9.148.112",
            .attack_type = "Credential Theft / Banking Fraud",
            .description =
                "Financial malware used for credential harvesting.",
        },

        .{
            .name = "Emotet Botnet",
            .malware_family = "Emotet",
            .c2_server = "91.214.124.55",
            .attack_type = "Malware Distribution",
            .description =
                "Botnet used to distribute ransomware payloads.",
        },

        .{
            .name = "Qbot Infrastructure",
            .malware_family = "QakBot",
            .c2_server = "198.54.120.44",
            .attack_type = "Enterprise Intrusion",
            .description =
                "Botnet targeting enterprise networks.",
        },
    };
}