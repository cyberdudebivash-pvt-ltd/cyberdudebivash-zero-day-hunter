const std = @import("std");

pub const WarModeState = enum {
    normal,
    elevated,
    crisis,
    cyber_war,
};

pub const DefensePosture = enum {
    standard,
    heightened,
    maximum,
};

pub const WarSignal = struct {
    global_risk: f32,
    active_campaigns: u32,
    reasoning_confidence: f32,
    anomaly_level: f32,
};

pub const WarStatus = struct {
    state: WarModeState,
    defense_posture: DefensePosture,
    confidence: f32,
    description: []const u8,
};

pub const CyberWarModeEngine = struct {
    allocator: std.mem.Allocator,

    state: WarModeState,
    posture: DefensePosture,

    last_status: ?WarStatus,

    pub fn init(allocator: std.mem.Allocator) CyberWarModeEngine {
        return CyberWarModeEngine{
            .allocator = allocator,
            .state = .normal,
            .posture = .standard,
            .last_status = null,
        };
    }

    pub fn deinit(self: *CyberWarModeEngine) void {
        _ = self;
    }

    fn determineState(score: f32) WarModeState {

        if (score >= 0.90) return .cyber_war;
        if (score >= 0.70) return .crisis;
        if (score >= 0.45) return .elevated;

        return .normal;
    }

    fn determinePosture(state: WarModeState) DefensePosture {

        return switch (state) {
            .normal => .standard,
            .elevated => .heightened,
            .crisis => .maximum,
            .cyber_war => .maximum,
        };
    }

    pub fn evaluate(self: *CyberWarModeEngine, signal: WarSignal) void {

        const composite_score =
            (signal.global_risk * 0.4) +
            (signal.reasoning_confidence * 0.3) +
            (signal.anomaly_level * 0.2) +
            (@as(f32, @floatFromInt(signal.active_campaigns)) / 20.0 * 0.1);

        const state = determineState(composite_score);
        const posture = determinePosture(state);

        self.state = state;
        self.posture = posture;

        var description: []const u8 = "System operating under normal cyber conditions.";

        switch (state) {
            .normal => {
                description = "Normal cyber threat conditions.";
            },
            .elevated => {
                description = "Elevated cyber threat level detected.";
            },
            .crisis => {
                description = "Severe coordinated cyber activity detected.";
            },
            .cyber_war => {
                description = "Global cyber war conditions detected.";
            },
        }

        self.last_status = WarStatus{
            .state = state,
            .defense_posture = posture,
            .confidence = composite_score,
            .description = description,
        };
    }

    pub fn getStatus(self: *CyberWarModeEngine) ?WarStatus {
        return self.last_status;
    }

    pub fn isWarMode(self: *CyberWarModeEngine) bool {
        return self.state == .cyber_war;
    }

    pub fn reset(self: *CyberWarModeEngine) void {

        self.state = .normal;
        self.posture = .standard;
        self.last_status = null;
    }
};