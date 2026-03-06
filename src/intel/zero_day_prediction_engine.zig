const std = @import("std");

pub const PredictionConfidence = enum {
    low,
    medium,
    high,
    critical,
};

pub const ExploitSignal = struct {
    target: []const u8,
    vector: []const u8,
    timestamp: i64,
};

pub const ZeroDayPrediction = struct {
    target: []const u8,
    vector: []const u8,
    confidence: PredictionConfidence,
    score: f64,
};

pub const ZeroDayPredictionEngine = struct {

    allocator: std.mem.Allocator,

    signals: std.ArrayList(ExploitSignal),

    predictions: std.ArrayList(ZeroDayPrediction),

    vector_frequency: std.StringHashMap(u32),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) ZeroDayPredictionEngine {

        return .{
            .allocator = allocator,
            .signals = std.ArrayList(ExploitSignal).init(allocator),
            .predictions = std.ArrayList(ZeroDayPrediction).init(allocator),
            .vector_frequency = std.StringHashMap(u32).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *ZeroDayPredictionEngine) void {

        for (self.signals.items) |s| {
            self.allocator.free(s.target);
            self.allocator.free(s.vector);
        }

        self.signals.deinit();

        for (self.predictions.items) |p| {
            self.allocator.free(p.target);
            self.allocator.free(p.vector);
        }

        self.predictions.deinit();

        var it = self.vector_frequency.iterator();

        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
        }

        self.vector_frequency.deinit();
    }

    // ------------------------------------------------
    // RECORD EXPLOIT SIGNAL
    // ------------------------------------------------
    pub fn recordSignal(
        self: *ZeroDayPredictionEngine,
        target: []const u8,
        vector: []const u8,
    ) !void {

        const t = try self.allocator.dupe(u8, target);
        const v = try self.allocator.dupe(u8, vector);

        const ts = std.time.timestamp();

        try self.signals.append(.{
            .target = t,
            .vector = v,
            .timestamp = ts,
        });

        try self.updateVectorFrequency(v);

        std.log.info(
            "[ZeroDayEngine] signal recorded target={s} vector={s}",
            .{ t, v },
        );
    }

    // ------------------------------------------------
    // UPDATE VECTOR FREQUENCY
    // ------------------------------------------------
    fn updateVectorFrequency(
        self: *ZeroDayPredictionEngine,
        vector: []const u8,
    ) !void {

        if (self.vector_frequency.get(vector)) |count| {

            try self.vector_frequency.put(vector, count + 1);

        } else {

            const key = try self.allocator.dupe(u8, vector);

            try self.vector_frequency.put(key, 1);
        }
    }

    // ------------------------------------------------
    // RUN PREDICTION ANALYSIS
    // ------------------------------------------------
    pub fn analyze(self: *ZeroDayPredictionEngine) !void {

        std.log.info(
            "[ZeroDayEngine] analyzing exploit patterns",
            .{},
        );

        var it = self.vector_frequency.iterator();

        while (it.next()) |entry| {

            const vector = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (count >= 4) {

                try self.createPrediction(
                    "unknown_target",
                    vector,
                    count,
                );
            }
        }

        try self.detectRapidExploitPattern();
    }

    // ------------------------------------------------
    // RAPID EXPLOIT DETECTION
    // ------------------------------------------------
    fn detectRapidExploitPattern(
        self: *ZeroDayPredictionEngine,
    ) !void {

        if (self.signals.items.len < 3) return;

        var i: usize = 0;

        while (i + 2 < self.signals.items.len) : (i += 1) {

            const a = self.signals.items[i];
            const b = self.signals.items[i + 1];
            const c = self.signals.items[i + 2];

            if (std.mem.eql(u8, a.vector, b.vector) and
                std.mem.eql(u8, b.vector, c.vector))
            {
                const delta = c.timestamp - a.timestamp;

                if (delta < 60) {

                    try self.createPrediction(
                        a.target,
                        a.vector,
                        5,
                    );
                }
            }
        }
    }

    // ------------------------------------------------
    // CREATE PREDICTION
    // ------------------------------------------------
    fn createPrediction(
        self: *ZeroDayPredictionEngine,
        target: []const u8,
        vector: []const u8,
        score_seed: u32,
    ) !void {

        const t = try self.allocator.dupe(u8, target);
        const v = try self.allocator.dupe(u8, vector);

        const score: f64 = @floatFromInt(score_seed) * 0.75;

        const confidence =
            if (score > 4.0)
                PredictionConfidence.critical
            else if (score > 3.0)
                PredictionConfidence.high
            else if (score > 2.0)
                PredictionConfidence.medium
            else
                PredictionConfidence.low;

        try self.predictions.append(.{
            .target = t,
            .vector = v,
            .confidence = confidence,
            .score = score,
        });

        std.log.warn(
            "[ZeroDayEngine] possible zero-day vector={s} confidence={}",
            .{ v, confidence },
        );
    }

    // ------------------------------------------------
    // REPORT
    // ------------------------------------------------
    pub fn report(self: *ZeroDayPredictionEngine) void {

        std.log.warn(
            "===== Zero-Day Prediction Report =====",
            .{},
        );

        for (self.predictions.items) |p| {

            std.log.warn(
                "Target={s} Vector={s} Confidence={} Score={d}",
                .{
                    p.target,
                    p.vector,
                    p.confidence,
                    p.score,
                },
            );
        }
    }

    // ------------------------------------------------
    // RESET
    // ------------------------------------------------
    pub fn reset(self: *ZeroDayPredictionEngine) void {

        for (self.signals.items) |s| {
            self.allocator.free(s.target);
            self.allocator.free(s.vector);
        }

        self.signals.clearRetainingCapacity();

        for (self.predictions.items) |p| {
            self.allocator.free(p.target);
            self.allocator.free(p.vector);
        }

        self.predictions.clearRetainingCapacity();

        self.vector_frequency.clearRetainingCapacity();
    }
};