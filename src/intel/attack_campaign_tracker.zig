const std = @import("std");

pub const Campaign = struct {
    name: []const u8,
    actor: []const u8,
    malware: []const u8,
    target_sector: []const u8,
    description: []const u8,
};

pub const CampaignHit = struct {
    ip: []const u8,
    campaign: Campaign,
};

pub fn track(ip: []const u8, malware: []const u8) void {

    std.debug.print(
        "🎯 Campaign intelligence analysis for {s}\n",
        .{ip},
    );

    const db = campaignDB();

    for (db) |c| {

        if (std.mem.eql(u8, c.malware, malware)) {

            reportCampaign(ip, c);
            return;
        }
    }

    std.debug.print(
        "ℹ️ No known campaign correlation\n",
        .{},
    );
}

fn reportCampaign(ip: []const u8, c: Campaign) void {

    std.debug.print(
        "\n🚨 Active Threat Campaign Detected\n",
        .{},
    );

    std.debug.print(
        "Target IP: {s}\n",
        .{ip},
    );

    std.debug.print(
        "Campaign: {s}\n",
        .{c.name},
    );

    std.debug.print(
        "Threat Actor: {s}\n",
        .{c.actor},
    );

    std.debug.print(
        "Malware: {s}\n",
        .{c.malware},
    );

    std.debug.print(
        "Target Sector: {s}\n",
        .{c.target_sector},
    );

    std.debug.print(
        "Description: {s}\n\n",
        .{c.description},
    );
}

fn campaignDB() []const Campaign {

    return &[_]Campaign{

        .{
            .name = "Mirai Global IoT Botnet",
            .actor = "UNC3843",
            .malware = "Mirai Variant",
            .target_sector = "IoT Infrastructure",
            .description =
                "Mass exploitation of IoT devices to build DDoS botnets.",
        },

        .{
            .name = "Cloud Container Escape Campaign",
            .actor = "Lazarus Group",
            .malware = "BeaverTail",
            .target_sector = "Cloud Infrastructure",
            .description =
                "Container escape exploits targeting Kubernetes clusters.",
        },

        .{
            .name = "Enterprise Banking Intrusions",
            .actor = "FIN7",
            .malware = "Carbanak",
            .target_sector = "Financial Institutions",
            .description =
                "Credential harvesting and lateral movement in enterprise networks.",
        },

        .{
            .name = "Supply Chain Compromise Operations",
            .actor = "APT41",
            .malware = "Winnti",
            .target_sector = "Software Supply Chains",
            .description =
                "Malware insertion into software distribution pipelines.",
        },

        .{
            .name = "Solar Infrastructure Intrusions",
            .actor = "APT29",
            .malware = "SUNBURST",
            .target_sector = "Government Networks",
            .description =
                "Long-term stealth espionage campaigns against government systems.",
        },
    };
}