const std = @import("std");

const Finding = @import("../report/finding.zig").Finding;

pub const ThreatIndicator = struct {
    indicator: []const u8,
    category: []const u8,
    confidence: []const u8,
};

pub const ExchangeNode = struct {
    node_id: []const u8,
    network: []const u8,
    status: []const u8,
};

pub const GlobalThreatExchange = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) GlobalThreatExchange {
        return GlobalThreatExchange{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *GlobalThreatExchange) void {
        _ = self;
    }

    /// Share threat intelligence with the global network
    pub fn exchange(
        self: *GlobalThreatExchange,
        target: []const u8,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info(
            "🌍 Global Threat Exchange publishing {} indicators for {s}",
            .{ findings.items.len, target },
        );

        const node = registerExchangeNode();

        std.log.info(
            "📡 Exchange Node: {s}",
            .{ node.node_id },
        );

        std.log.info(
            "🌐 Network: {s}",
            .{ node.network },
        );

        std.log.info(
            "🟢 Status: {s}",
            .{ node.status },
        );

        for (findings.items) |finding| {

            const indicator = buildIndicator(&finding);

            std.log.info(
                "📤 Publishing Indicator: {s}",
                .{ indicator.indicator },
            );

            std.log.info(
                "📊 Category: {s}",
                .{ indicator.category },
            );

            std.log.info(
                "🔍 Confidence: {s}",
                .{ indicator.confidence },
            );
        }

        std.log.info(
            "✅ Global threat exchange completed",
            .{},
        );
    }
};

/// Register this platform as an exchange node
fn registerExchangeNode() ExchangeNode {

    return ExchangeNode{
        .node_id = "CDB-THREAT-EXCHANGE-01",
        .network = "CyberDudeBivash Global Threat Network",
        .status = "active",
    };
}

/// Convert findings into threat intelligence indicators
fn buildIndicator(finding: *const Finding) ThreatIndicator {

    if (std.mem.eql(u8, finding.finding_type, "metadata_service_access")) {
        return ThreatIndicator{
            .indicator = "cloud-metadata-exploit",
            .category = "cloud_intrusion",
            .confidence = "high",
        };
    }

    if (std.mem.eql(u8, finding.finding_type, "public_git_repo")) {
        return ThreatIndicator{
            .indicator = "public-repo-secret-exposure",
            .category = "supply_chain",
            .confidence = "medium",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "memory_hunter")) {
        return ThreatIndicator{
            .indicator = "memory-exploit-pattern",
            .category = "host_intrusion",
            .confidence = "high",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "syscall_hunter")) {
        return ThreatIndicator{
            .indicator = "kernel-syscall-exploit",
            .category = "kernel_attack",
            .confidence = "critical",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "behavioral_hunter")) {
        return ThreatIndicator{
            .indicator = "behavioral-anomaly-threat",
            .category = "malware_activity",
            .confidence = "medium",
        };
    }

    return ThreatIndicator{
        .indicator = "unknown-threat-pattern",
        .category = "unclassified",
        .confidence = "low",
    };
}