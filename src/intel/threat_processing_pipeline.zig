const std = @import("std");

pub const PipelineEventType = enum {
    RawTelemetry,
    NormalizedSignal,
    IOCDiscovered,
    ThreatCorrelated,
    RiskScored,
};

pub const ThreatPriority = enum {
    low,
    medium,
    high,
    critical,
};

pub const IOCType = enum {
    ip,
    domain,
    url,
    file_hash,
    process_name,
    registry_key,
};

pub const IOC = struct {
    ioc_type: IOCType,
    value: []const u8,
};

pub const TelemetryEvent = struct {
    source: []const u8,
    payload: []const u8,
    timestamp: i64,
};

pub const ThreatSignal = struct {
    source: []const u8,
    normalized_data: []const u8,
    timestamp: i64,
};

pub const CorrelatedThreat = struct {
    signals: []ThreatSignal,
    score: f32,
};

pub const RiskAssessment = struct {
    score: f32,
    priority: ThreatPriority,
};

pub const PipelineContext = struct {
    allocator: std.mem.Allocator,
};

pub const ThreatProcessingPipeline = struct {

    allocator: std.mem.Allocator,

    telemetry_queue: std.ArrayList(TelemetryEvent),
    signal_queue: std.ArrayList(ThreatSignal),
    correlated_queue: std.ArrayList(CorrelatedThreat),

    pub fn init(allocator: std.mem.Allocator) ThreatProcessingPipeline {

        return ThreatProcessingPipeline{
            .allocator = allocator,
            .telemetry_queue = std.ArrayList(TelemetryEvent).init(allocator),
            .signal_queue = std.ArrayList(ThreatSignal).init(allocator),
            .correlated_queue = std.ArrayList(CorrelatedThreat).init(allocator),
        };

    }

    pub fn deinit(self: *ThreatProcessingPipeline) void {

        self.telemetry_queue.deinit();
        self.signal_queue.deinit();
        self.correlated_queue.deinit();

    }

    //
    // --------------------------------------
    // INGEST TELEMETRY
    // --------------------------------------
    //

    pub fn ingestTelemetry(
        self: *ThreatProcessingPipeline,
        source: []const u8,
        payload: []const u8,
        timestamp: i64,
    ) !void {

        const event = TelemetryEvent{
            .source = source,
            .payload = payload,
            .timestamp = timestamp,
        };

        try self.telemetry_queue.append(event);

    }

    //
    // --------------------------------------
    // NORMALIZATION STAGE
    // --------------------------------------
    //

    pub fn normalizeTelemetry(self: *ThreatProcessingPipeline) !void {

        var i: usize = 0;

        while (i < self.telemetry_queue.items.len) : (i += 1) {

            const telemetry = self.telemetry_queue.items[i];

            const signal = ThreatSignal{
                .source = telemetry.source,
                .normalized_data = telemetry.payload,
                .timestamp = telemetry.timestamp,
            };

            try self.signal_queue.append(signal);

        }

        self.telemetry_queue.clearRetainingCapacity();

    }

    //
    // --------------------------------------
    // IOC EXTRACTION
    // --------------------------------------
    //

    pub fn extractIOCs(
        self: *ThreatProcessingPipeline,
        allocator: std.mem.Allocator,
    ) !std.ArrayList(IOC) {

        var iocs = std.ArrayList(IOC).init(allocator);

        for (self.signal_queue.items) |signal| {

            if (std.mem.indexOf(u8, signal.normalized_data, "http")) |_| {

                try iocs.append(.{
                    .ioc_type = .url,
                    .value = signal.normalized_data,
                });

            }

            if (std.mem.indexOf(u8, signal.normalized_data, "192.")) |_| {

                try iocs.append(.{
                    .ioc_type = .ip,
                    .value = signal.normalized_data,
                });

            }

        }

        return iocs;

    }

    //
    // --------------------------------------
    // THREAT CORRELATION
    // --------------------------------------
    //

    pub fn correlateSignals(self: *ThreatProcessingPipeline) !void {

        if (self.signal_queue.items.len == 0) return;

        var score: f32 = 0;

        for (self.signal_queue.items) |_| {

            score += 0.2;

        }

        const threat = CorrelatedThreat{
            .signals = self.signal_queue.items,
            .score = score,
        };

        try self.correlated_queue.append(threat);

        self.signal_queue.clearRetainingCapacity();

    }

    //
    // --------------------------------------
    // RISK SCORING
    // --------------------------------------
    //

    pub fn scoreThreat(threat: CorrelatedThreat) RiskAssessment {

        var priority: ThreatPriority = .low;

        if (threat.score > 2.0) {

            priority = .critical;

        } else if (threat.score > 1.5) {

            priority = .high;

        } else if (threat.score > 1.0) {

            priority = .medium;

        }

        return RiskAssessment{
            .score = threat.score,
            .priority = priority,
        };

    }

    //
    // --------------------------------------
    // PROCESS PIPELINE
    // --------------------------------------
    //

    pub fn process(self: *ThreatProcessingPipeline) !void {

        try self.normalizeTelemetry();

        try self.correlateSignals();

        for (self.correlated_queue.items) |threat| {

            const risk = scoreThreat(threat);

            std.debug.print(
                "Threat Score: {d} Priority: {any}\n",
                .{ risk.score, risk.priority },
            );

        }

        self.correlated_queue.clearRetainingCapacity();

    }

};