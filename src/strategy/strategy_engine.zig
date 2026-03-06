const std = @import("std");

const Finding = @import("../report/finding.zig").Finding;

pub const Strategy = struct {
    action: []const u8,
    recommendation: []const u8,
};

pub const StrategyEngine = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) StrategyEngine {
        return StrategyEngine{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *StrategyEngine) void {
        _ = self;
    }

    /// Generate defensive strategies from findings
    pub fn generate(
        self: *StrategyEngine,
        target: []const u8,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info(
            "🛡 Strategy Engine generating responses for {} findings on {s}",
            .{ findings.items.len, target },
        );

        for (findings.items) |finding| {

            const strategy = determineStrategy(&finding);

            std.log.info(
                "⚙ Strategy for {s}: {s}",
                .{ finding.hunter, strategy.action },
            );

            std.log.info(
                "💡 Recommendation: {s}",
                .{ strategy.recommendation },
            );
        }

        std.log.info(
            "✅ Strategy generation complete",
            .{},
        );
    }
};

/// Determine strategy based on finding type
fn determineStrategy(finding: *const Finding) Strategy {

    if (std.mem.eql(u8, finding.finding_type, "metadata_service_access")) {
        return Strategy{
            .action = "block_metadata_endpoint",
            .recommendation = "Restrict access to cloud metadata service via firewall or IAM policies",
        };
    }

    if (std.mem.eql(u8, finding.finding_type, "public_git_repo")) {
        return Strategy{
            .action = "audit_repository",
            .recommendation = "Audit repository for secrets and rotate exposed credentials",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "memory_hunter")) {
        return Strategy{
            .action = "memory_forensics",
            .recommendation = "Perform full memory analysis and isolate compromised host",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "syscall_hunter")) {
        return Strategy{
            .action = "process_isolation",
            .recommendation = "Investigate suspicious syscall patterns and isolate affected process",
        };
    }

    if (std.mem.eql(u8, finding.hunter, "behavioral_hunter")) {
        return Strategy{
            .action = "behavior_analysis",
            .recommendation = "Investigate abnormal behavior patterns and review logs",
        };
    }

    return Strategy{
        .action = "investigate",
        .recommendation = "Manual investigation recommended",
    };
}