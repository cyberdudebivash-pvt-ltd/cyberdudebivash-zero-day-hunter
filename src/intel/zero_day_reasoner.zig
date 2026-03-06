const std = @import("std");

pub const VulnerabilitySignal = struct {
    component: []const u8,
    behavior: []const u8,
    source: []const u8,
    severity: u8,
    timestamp: i64,
};

pub const ZeroDayHypothesis = struct {
    component: []const u8,
    suspected_issue: []const u8,
    reasoning: []const u8,
    confidence: f32,
};

pub const ZeroDayReasoner = struct {

    allocator: std.mem.Allocator,

    signals: std.ArrayList(VulnerabilitySignal),
    hypotheses: std.ArrayList(ZeroDayHypothesis),

    pub fn init(allocator: std.mem.Allocator) ZeroDayReasoner {
        return ZeroDayReasoner{
            .allocator = allocator,
            .signals = std.ArrayList(VulnerabilitySignal).init(allocator),
            .hypotheses = std.ArrayList(ZeroDayHypothesis).init(allocator),
        };
    }

    pub fn deinit(self: *ZeroDayReasoner) void {
        self.signals.deinit();
        self.hypotheses.deinit();
    }

    /// ingest anomaly or vulnerability signal
    pub fn ingestSignal(
        self: *ZeroDayReasoner,
        component: []const u8,
        behavior: []const u8,
        source: []const u8,
        severity: u8,
    ) !void {

        const signal = VulnerabilitySignal{
            .component = component,
            .behavior = behavior,
            .source = source,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        };

        try self.signals.append(signal);

        std.log.info(
            "🔎 Vulnerability signal recorded: {s} ({s})",
            .{ component, behavior },
        );
    }

    /// analyze signals to generate zero-day hypotheses
    pub fn analyzeSignals(self: *ZeroDayReasoner) !void {

        std.log.info(
            "🧠 Running zero-day reasoning analysis",
            .{},
        );

        var component_map = std.StringHashMap(usize).init(self.allocator);
        defer component_map.deinit();

        for (self.signals.items) |signal| {

            const entry = try component_map.getOrPut(signal.component);

            if (!entry.found_existing)
                entry.value_ptr.* = 0;

            entry.value_ptr.* += 1;
        }

        var it = component_map.iterator();

        while (it.next()) |entry| {

            const component = entry.key_ptr.*;
            const signal_count = entry.value_ptr.*;

            if (signal_count < 2)
                continue;

            const confidence =
                @as(f32, @floatFromInt(signal_count)) / 10.0;

            const hypothesis = ZeroDayHypothesis{
                .component = component,
                .suspected_issue = "potential memory corruption or logic flaw",
                .reasoning = "multiple anomaly signals detected across subsystems",
                .confidence = confidence,
            };

            try self.hypotheses.append(hypothesis);

            std.log.warn(
                "⚠️ Zero-day hypothesis generated for {s} (confidence {d:.2})",
                .{ component, confidence },
            );
        }
    }

    /// print hypotheses
    pub fn report(self: *ZeroDayReasoner) void {

        std.log.info(
            "📊 Zero-Day Research Report",
            .{},
        );

        for (self.hypotheses.items) |h| {

            std.log.info(
                "Component: {s}",
                .{h.component},
            );

            std.log.info(
                "Suspected Issue: {s}",
                .{h.suspected_issue},
            );

            std.log.info(
                "Reasoning: {s}",
                .{h.reasoning},
            );

            std.log.info(
                "Confidence: {d:.2}",
                .{h.confidence},
            );
        }
    }

    /// export hypotheses as JSON
    pub fn exportJson(self: *ZeroDayReasoner) ![]u8 {

        var buffer = std.ArrayList(u8).init(self.allocator);

        try buffer.appendSlice("{\"zero_day_hypotheses\":[");

        for (self.hypotheses.items, 0..) |h, i| {

            if (i != 0)
                try buffer.appendSlice(",");

            const entry = try std.fmt.allocPrint(
                self.allocator,
                "{{\"component\":\"{s}\",\"issue\":\"{s}\",\"confidence\":{d:.2}}}",
                .{
                    h.component,
                    h.suspected_issue,
                    h.confidence,
                },
            );

            defer self.allocator.free(entry);

            try buffer.appendSlice(entry);
        }

        try buffer.appendSlice("]}");

        return buffer.toOwnedSlice();
    }
};