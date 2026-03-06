const std = @import("std");

pub const DefenseAction = enum {
    monitor,
    increase_logging,
    enable_waf,
    block_ip,
    isolate_host,
    ddos_protection,
};

pub const LearningEvent = struct {
    action: DefenseAction,
    success: bool,
    anomaly_score: f32,
    campaign_detected: bool,
    timestamp: i64,
};

pub const LearnedPolicy = struct {
    action: DefenseAction,
    effectiveness_score: f32,
    observations: u32,
};

pub const PolicyRecommendation = struct {
    action: DefenseAction,
    confidence: f32,
};

pub const SelfLearningDefenseAI = struct {
    allocator: std.mem.Allocator,

    events: std.ArrayList(LearningEvent),
    policies: std.AutoHashMap(DefenseAction, LearnedPolicy),

    pub fn init(allocator: std.mem.Allocator) SelfLearningDefenseAI {
        return SelfLearningDefenseAI{
            .allocator = allocator,
            .events = std.ArrayList(LearningEvent).init(allocator),
            .policies = std.AutoHashMap(DefenseAction, LearnedPolicy).init(allocator),
        };
    }

    pub fn deinit(self: *SelfLearningDefenseAI) void {
        self.events.deinit();
        self.policies.deinit();
    }

    pub fn recordEvent(
        self: *SelfLearningDefenseAI,
        event: LearningEvent,
    ) !void {
        try self.events.append(event);
    }

    fn updatePolicy(
        self: *SelfLearningDefenseAI,
        action: DefenseAction,
        success: bool,
    ) !void {

        const entry = try self.policies.getOrPut(action);

        if (!entry.found_existing) {
            entry.value_ptr.* = LearnedPolicy{
                .action = action,
                .effectiveness_score = if (success) 1.0 else 0.0,
                .observations = 1,
            };
            return;
        }

        var policy = entry.value_ptr.*;

        const score = if (success) 1.0 else 0.0;

        const total =
            (policy.effectiveness_score * @as(f32, @floatFromInt(policy.observations))) +
            score;

        policy.observations += 1;

        policy.effectiveness_score =
            total / @as(f32, @floatFromInt(policy.observations));

        entry.value_ptr.* = policy;
    }

    pub fn learn(self: *SelfLearningDefenseAI) !void {

        for (self.events.items) |event| {
            try self.updatePolicy(event.action, event.success);
        }
    }

    pub fn recommendAction(
        self: *SelfLearningDefenseAI,
        anomaly_score: f32,
        campaign_detected: bool,
    ) PolicyRecommendation {

        var best_action: DefenseAction = .monitor;
        var best_score: f32 = 0.0;

        var it = self.policies.iterator();

        while (it.next()) |entry| {

            const policy = entry.value_ptr.*;

            var score = policy.effectiveness_score;

            if (campaign_detected)
                score += 0.2;

            score += anomaly_score * 0.3;

            if (score > best_score) {
                best_score = score;
                best_action = policy.action;
            }
        }

        return PolicyRecommendation{
            .action = best_action,
            .confidence = best_score,
        };
    }

    pub fn policyCount(self: *SelfLearningDefenseAI) usize {
        return self.policies.count();
    }

    pub fn clearEvents(self: *SelfLearningDefenseAI) void {
        self.events.clearRetainingCapacity();
    }
};