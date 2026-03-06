const std = @import("std");

/// Threat severity score
pub const ThreatLevel = enum {
    benign,
    suspicious,
    malicious,
    critical,
};

/// IOC structure
pub const IOC = struct {
    indicator: []const u8,
    source: []const u8,
};

/// Detection signal from hunters
pub const DetectionSignal = struct {
    target: []const u8,
    title: []const u8,
    severity: []const u8,
};

/// Recon data from scanner
pub const ReconSignal = struct {
    target: []const u8,
    open_ports: []const u16,
};

/// Final fused intelligence event
pub const ThreatEvent = struct {
    target: []const u8,
    score: u32,
    level: ThreatLevel,
    summary: []const u8,
};

/// Threat fusion engine
pub const ThreatFusion = struct {

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ThreatFusion {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ThreatFusion) void {
        _ = self;
    }

    /// Score a detection signal
    fn scoreDetection(
        signal: DetectionSignal,
    ) u32 {

        if (std.mem.eql(u8, signal.severity, "critical")) return 90;
        if (std.mem.eql(u8, signal.severity, "high")) return 70;
        if (std.mem.eql(u8, signal.severity, "medium")) return 40;
        if (std.mem.eql(u8, signal.severity, "low")) return 20;

        return 10;
    }

    /// Score recon data
    fn scoreRecon(
        signal: ReconSignal,
    ) u32 {

        var score: u32 = 0;

        for (signal.open_ports) |port| {

            if (port == 22) score += 15;
            if (port == 445) score += 20;
            if (port == 3389) score += 25;
            if (port == 3306) score += 10;
        }

        return score;
    }

    /// Convert numeric score to threat level
    fn classify(score: u32) ThreatLevel {

        if (score >= 90) return .critical;
        if (score >= 60) return .malicious;
        if (score >= 30) return .suspicious;

        return .benign;
    }

    /// Fuse signals into a threat event
    pub fn fuse(
        self: *ThreatFusion,
        detection: ?DetectionSignal,
        recon: ?ReconSignal,
    ) !ThreatEvent {

        var score: u32 = 0;

        if (detection) |d| {
            score += scoreDetection(d);
        }

        if (recon) |r| {
            score += scoreRecon(r);
        }

        const level = classify(score);

        const summary = try std.fmt.allocPrint(
            self.allocator,
            "Threat score={} level={}",
            .{ score, level },
        );

        const target = if (detection) |d|
            d.target
        else if (recon) |r|
            r.target
        else
            "unknown";

        return ThreatEvent{
            .target = target,
            .score = score,
            .level = level,
            .summary = summary,
        };
    }

    /// Send fused event to SOC pipeline
    pub fn emit(self: *ThreatFusion, event: ThreatEvent) void {

        std.log.warn(
            "[ThreatFusion] target={s} score={} level={}",
            .{ event.target, event.score, event.level },
        );

        std.log.info(
            "[ThreatFusion] summary: {s}",
            .{event.summary},
        );

        _ = self;
    }
};