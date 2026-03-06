const std = @import("std");

const Finding = @import("../report/finding.zig").Finding;

pub const RuleEngine = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) RuleEngine {
        std.log.info("Initializing custom rule engine", .{});
        return RuleEngine{ .allocator = allocator };
    }

    pub fn deinit(self: *RuleEngine) void {
        _ = self;
    }

    /// Evaluate custom detection rules against target
    pub fn evaluate(
        self: *RuleEngine,
        target: []const u8,
        findings: *std.ArrayList(Finding),
    ) !void {
        _ = self;

        // Custom rule: Cloud metadata access
        if (std.mem.indexOf(u8, target, "169.254.169.254") != null or
            std.mem.indexOf(u8, target, "metadata") != null)
        {
            try findings.append(.{
                .hunter = "rule_engine",
                .finding_type = "metadata_service_access",
                .severity = "high",
                .description = "Cloud metadata endpoint access detected",
            });
        }

        // Custom rule: Git exposure
        if (std.mem.indexOf(u8, target, ".git") != null or
            std.mem.indexOf(u8, target, "git_exposure") != null)
        {
            try findings.append(.{
                .hunter = "rule_engine",
                .finding_type = "public_git_repo",
                .severity = "medium",
                .description = "Public git repository exposure detected",
            });
        }

        // Custom rule: Suspicious process execution
        if (std.mem.indexOf(u8, target, "cmd.exe") != null or
            std.mem.indexOf(u8, target, "wscript") != null)
        {
            try findings.append(.{
                .hunter = "rule_engine",
                .finding_type = "suspicious_process",
                .severity = "high",
                .description = "Suspicious process execution detected",
            });
        }
    }
};
