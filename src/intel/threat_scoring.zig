const std = @import("std");

const Finding = @import("../report/finding.zig").Finding;

pub const ThreatScore = struct {
    score: u32,
    severity: []const u8,
};

pub const ThreatScoringEngine = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ThreatScoringEngine {
        return ThreatScoringEngine{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ThreatScoringEngine) void {
        _ = self;
    }

    /// Evaluate all findings and calculate threat scores
    pub fn evaluate(
        self: *ThreatScoringEngine,
        target: []const u8,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info(
            "📊 Threat Scoring Engine evaluating {} findings for {s}",
            .{ findings.items.len, target },
        );

        for (findings.items) |*finding| {

            const score = calculateScore(finding);

            const severity = severityFromScore(score);

            finding.severity = severity;

            std.log.info(
                "⚠️ Finding scored: {s} → {} ({s})",
                .{
                    finding.hunter,
                    score,
                    severity,
                },
            );
        }

        std.log.info(
            "✅ Threat scoring complete",
            .{},
        );
    }
};

/// Calculate threat score based on heuristics
fn calculateScore(finding: *Finding) u32 {

    var score: u32 = 10;

    if (std.mem.eql(u8, finding.hunter, "memory_hunter")) {
        score += 30;
    }

    if (std.mem.eql(u8, finding.hunter, "syscall_hunter")) {
        score += 40;
    }

    if (std.mem.eql(u8, finding.hunter, "behavioral_hunter")) {
        score += 20;
    }

    if (std.mem.eql(u8, finding.hunter, "code_exposure")) {
        score += 25;
    }

    if (std.mem.eql(u8, finding.finding_type, "metadata_service_access")) {
        score += 40;
    }

    if (std.mem.eql(u8, finding.finding_type, "public_git_repo")) {
        score += 15;
    }

    if (score > 100) {
        score = 100;
    }

    return score;
}

/// Convert score to severity classification
fn severityFromScore(score: u32) []const u8 {

    if (score >= 80) {
        return "critical";
    }

    if (score >= 60) {
        return "high";
    }

    if (score >= 40) {
        return "medium";
    }

    return "low";
}