const std = @import("std");

pub const DefenseActionType = enum {
    monitor,
    alert_soc,
    increase_logging,
    block_ip,
    enable_waf_rules,
    isolate_host,
    activate_ddos_protection,
};

pub const DefenseDecisionLevel = enum {
    informational,
    precautionary,
    defensive,
    aggressive,
};

pub const DefenseSignal = struct {
    global_risk_score: f32,
    anomaly_score: f32,
    campaign_detected: bool,
    reasoning_confidence: f32,
    actor: ?[]const u8,
};

pub const DefenseDecision = struct {
    action: DefenseActionType,
    level: DefenseDecisionLevel,
    confidence: f32,
    description: []const u8,
};

pub const AutonomousDefenseAI = struct {
    allocator: std.mem.Allocator,

    decisions: std.ArrayList(DefenseDecision),

    pub fn init(allocator: std.mem.Allocator) AutonomousDefenseAI {
        return AutonomousDefenseAI{
            .allocator = allocator,
            .decisions = std.ArrayList(DefenseDecision).init(allocator),
        };
    }

    pub fn deinit(self: *AutonomousDefenseAI) void {
        self.decisions.deinit();
    }

    fn determineLevel(score: f32) DefenseDecisionLevel {

        if (score >= 0.85) return .aggressive;
        if (score >= 0.65) return .defensive;
        if (score >= 0.40) return .precautionary;

        return .informational;
    }

    pub fn analyze(self: *AutonomousDefenseAI, signal: DefenseSignal) !void {

        self.decisions.clearRetainingCapacity();

        const composite_risk =
            (signal.global_risk_score * 0.4) +
            (signal.anomaly_score * 0.3) +
            (signal.reasoning_confidence * 0.3);

        const level = determineLevel(composite_risk);

        if (level == .informational) {

            try self.decisions.append(.{
                .action = .monitor,
                .level = level,
                .confidence = composite_risk,
                .description = "Monitor environment for abnormal behavior.",
            });

            return;
        }

        if (level == .precautionary) {

            try self.decisions.append(.{
                .action = .increase_logging,
                .level = level,
                .confidence = composite_risk,
                .description = "Increase telemetry collection and monitoring.",
            });

            try self.decisions.append(.{
                .action = .alert_soc,
                .level = level,
                .confidence = composite_risk,
                .description = "Notify SOC analysts of suspicious activity.",
            });
        }

        if (level == .defensive) {

            try self.decisions.append(.{
                .action = .enable_waf_rules,
                .level = level,
                .confidence = composite_risk,
                .description = "Enable web application firewall protections.",
            });

            try self.decisions.append(.{
                .action = .alert_soc,
                .level = level,
                .confidence = composite_risk,
                .description = "Escalate alert to SOC team.",
            });
        }

        if (level == .aggressive) {

            try self.decisions.append(.{
                .action = .block_ip,
                .level = level,
                .confidence = composite_risk,
                .description = "Block malicious IP addresses immediately.",
            });

            try self.decisions.append(.{
                .action = .activate_ddos_protection,
                .level = level,
                .confidence = composite_risk,
                .description = "Activate DDoS protection mechanisms.",
            });

            try self.decisions.append(.{
                .action = .isolate_host,
                .level = level,
                .confidence = composite_risk,
                .description = "Isolate compromised hosts from network.",
            });
        }

        if (signal.campaign_detected) {

            try self.decisions.append(.{
                .action = .alert_soc,
                .level = .aggressive,
                .confidence = 0.9,
                .description = "Coordinated campaign detected. Escalate immediately.",
            });
        }

        if (signal.actor) |actor| {

            if (std.mem.eql(u8, actor, "Lazarus Group")) {

                try self.decisions.append(.{
                    .action = .increase_logging,
                    .level = .defensive,
                    .confidence = 0.85,
                    .description = "Monitor financial infrastructure activity.",
                });
            }

            if (std.mem.eql(u8, actor, "APT29")) {

                try self.decisions.append(.{
                    .action = .increase_logging,
                    .level = .defensive,
                    .confidence = 0.80,
                    .description = "Increase monitoring of authentication systems.",
                });
            }
        }
    }

    pub fn getDecisions(self: *AutonomousDefenseAI) []DefenseDecision {
        return self.decisions.items;
    }
};