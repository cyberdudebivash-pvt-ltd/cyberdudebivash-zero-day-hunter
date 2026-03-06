const std = @import("std");

const Finding = @import("../report/finding.zig").Finding;

const RuleEngine = @import("rule_engine.zig").RuleEngine;
const SigmaEngine = @import("sigma_engine.zig").SigmaEngine;
const YaraEngine = @import("yara_engine.zig").YaraEngine;

pub const DetectionEngine = struct {
    allocator: std.mem.Allocator,

    rule_engine: RuleEngine,
    sigma_engine: SigmaEngine,
    yara_engine: YaraEngine,

    pub fn init(allocator: std.mem.Allocator) DetectionEngine {
        return DetectionEngine{
            .allocator = allocator,
            .rule_engine = RuleEngine.init(allocator),
            .sigma_engine = SigmaEngine.init(allocator),
            .yara_engine = YaraEngine.init(allocator),
        };
    }

    pub fn deinit(self: *DetectionEngine) void {
        self.rule_engine.deinit();
        self.sigma_engine.deinit();
        self.yara_engine.deinit();
    }

    /// Main detection pipeline
    pub fn analyze(
        self: *DetectionEngine,
        target: []const u8,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info(
            "🔬 Detection Engine analyzing {} findings for {s}",
            .{ findings.items.len, target },
        );

        // --------------------------------
        // CUSTOM RULE ENGINE
        // --------------------------------

        try self.rule_engine.evaluate(target, findings);

        // --------------------------------
        // SIGMA DETECTION ENGINE
        // --------------------------------

        try self.sigma_engine.evaluate(target, findings);

        // --------------------------------
        // YARA DETECTION ENGINE
        // --------------------------------

        try self.yara_engine.evaluate(target, findings);

        std.log.info(
            "✅ Detection analysis complete. Findings now: {}",
            .{ findings.items.len },
        );
    }
};