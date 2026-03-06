const std = @import("std");

const Finding = @import("../report/finding.zig").Finding;

pub const AttackEvent = struct {
    source: []const u8,
    threat_type: []const u8,
    severity: []const u8,
};

pub const Campaign = struct {
    name: []const u8,
    stage: []const u8,
};

pub const CommandCenterEngine = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) CommandCenterEngine {
        return CommandCenterEngine{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *CommandCenterEngine) void {
        _ = self;
    }

    /// Main SOC orchestration routine
    pub fn orchestrate(
        self: *CommandCenterEngine,
        target: []const u8,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info(
            "🛰️ Command Center orchestrating security operations for {s}",
            .{ target },
        );

        std.log.info(
            "📊 Aggregating {} threat signals",
            .{ findings.items.len },
        );

        for (findings.items) |finding| {

            const event = convertToEvent(&finding);

            std.log.info(
                "🚨 Threat Event: {s}",
                .{ event.threat_type },
            );

            std.log.info(
                "🌍 Source: {s}",
                .{ event.source },
            );

            std.log.info(
                "🔥 Severity: {s}",
                .{ event.severity },
            );

            const campaign = correlateCampaign(&finding);

            std.log.info(
                "🎯 Campaign correlation: {s}",
                .{ campaign.name },
            );

            std.log.info(
                "📈 Campaign stage: {s}",
                .{ campaign.stage },
            );
        }

        std.log.info(
            "✅ Command center orchestration complete",
            .{},
        );
    }
};

/// Convert findings into command center threat events
fn convertToEvent(finding: *const Finding) AttackEvent {

    if (std.mem.eql(u8, finding.finding_type, "metadata_service_access")) {
        return AttackEvent{
            .source = "cloud_environment",
            .threat_type = "cloud_escape_attempt",
            .severity = finding.severity,
        };
    }

    if (std.mem.eql(u8, finding.finding_type, "public_git_repo")) {
        return AttackEvent{
            .source = "source_code_repository",
            .threat_type = "repository_exposure",
            .severity = finding.severity,
        };
    }

    if (std.mem.eql(u8, finding.hunter, "memory_hunter")) {
        return AttackEvent{
            .source = "host_memory",
            .threat_type = "memory_exploit",
            .severity = finding.severity,
        };
    }

    if (std.mem.eql(u8, finding.hunter, "syscall_hunter")) {
        return AttackEvent{
            .source = "kernel_runtime",
            .threat_type = "kernel_attack",
            .severity = finding.severity,
        };
    }

    if (std.mem.eql(u8, finding.hunter, "behavioral_hunter")) {
        return AttackEvent{
            .source = "runtime_behavior",
            .threat_type = "behavioral_anomaly",
            .severity = finding.severity,
        };
    }

    return AttackEvent{
        .source = "unknown",
        .threat_type = "unclassified_threat",
        .severity = finding.severity,
    };
}

/// Correlate findings with known attack campaigns
fn correlateCampaign(finding: *const Finding) Campaign {

    if (std.mem.eql(u8, finding.finding_type, "metadata_service_access")) {
        return Campaign{
            .name = "Cloud Credential Harvesting",
            .stage = "Initial Access",
        };
    }

    if (std.mem.eql(u8, finding.finding_type, "public_git_repo")) {
        return Campaign{
            .name = "Supply Chain Recon",
            .stage = "Reconnaissance",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "memory_hunter")) {
        return Campaign{
            .name = "Privilege Escalation Campaign",
            .stage = "Exploitation",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "syscall_hunter")) {
        return Campaign{
            .name = "Kernel Intrusion",
            .stage = "Persistence",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "behavioral_hunter")) {
        return Campaign{
            .name = "Data Exfiltration Campaign",
            .stage = "Exfiltration",
        };
    }

    return Campaign{
        .name = "Unknown Threat Campaign",
        .stage = "Investigation",
    };
}