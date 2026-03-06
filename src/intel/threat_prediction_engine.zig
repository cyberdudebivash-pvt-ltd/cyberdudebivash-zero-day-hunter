const std = @import("std");

const Aggregator = @import("threat_signal_aggregator.zig");
const Analyzer = @import("threat_trend_analyzer.zig");
const Predictor = @import("threat_wave_predictor.zig");

const Types = @import("threat_prediction_types.zig");
const ThreatSignal = Types.ThreatSignal;

pub fn run(
    allocator: std.mem.Allocator,
    signals: []ThreatSignal,
) !void {

    const map = try Aggregator.aggregate(allocator, signals);

    const trends = try Analyzer.analyze(allocator, map);

    const predictions = try Predictor.predict(allocator, trends);

    for (predictions) |p| {

        std.log.info(
            "predicted threat={} risk={}",
            .{ p.threat_type, p.predicted_risk },
        );
    }
}