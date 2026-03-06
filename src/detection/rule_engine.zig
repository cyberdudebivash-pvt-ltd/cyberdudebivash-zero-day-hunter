const std = @import("std");

const rule_loader = @import("rule_loader.zig");
const rule_mod = @import("rule.zig");
const Finding = @import("../hunters/interface.zig").Finding;

pub const RuleEngine = struct {
    allocator: std.mem.Allocator,
    rules: std.ArrayList(rule_mod.Rule),

    pub fn init(allocator: std.mem.Allocator) !RuleEngine {

        std.log.info("Initializing rule engine", .{});

        var engine = RuleEngine{
            .allocator = allocator,
            .rules = std.ArrayList(rule_mod.Rule).init(allocator),
        };

        try engine.loadRules();

        return engine;
    }

    fn loadRules(self: *RuleEngine) !void {

        std.log.info("Loading detection rules", .{});

        const loaded = try rule_loader.load(self.allocator);

        for (loaded.items) |rule| {
            try self.rules.append(rule);
        }

        std.log.info("Rules loaded: {}", .{self.rules.items.len});
    }

    /// Process findings through rule engine
    pub fn process(
        self: *RuleEngine,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info("Running rule engine against findings", .{});

        if (self.rules.items.len == 0) {
            std.log.warn("No rules loaded — skipping rule evaluation", .{});
            return;
        }

        for (findings.items) |*finding| {

            for (self.rules.items) |rule| {

                if (evaluate(rule, finding)) {

                    std.log.info(
                        "Rule matched: {s} → finding: {s}",
                        .{ rule.name, finding.finding_type },
                    );

                    applyRule(rule, finding);
                }
            }
        }

        std.log.info("Rule engine processing completed", .{});
    }

};

/// Evaluate whether a rule matches a finding
fn evaluate(rule: rule_mod.Rule, finding: *Finding) bool {

    if (std.mem.eql(u8, rule.finding_type, finding.finding_type)) {
        return true;
    }

    return false;
}

/// Apply rule modifications to a finding
fn applyRule(rule: rule_mod.Rule, finding: *Finding) void {

    if (rule.override_severity) |severity| {
        finding.severity = severity;
    }

    if (rule.override_description) |desc| {
        finding.description = desc;
    }
}