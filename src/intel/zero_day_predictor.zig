const std = @import("std");

pub const Telemetry = struct {
    target: []const u8,
    service: []const u8,
    exploit_attempts: usize,
    unusual_patterns: usize,
};

pub const Prediction = struct {
    software: []const u8,
    risk_score: f32,
    reason: []const u8,
};

pub fn analyze(events: []const Telemetry) void {

    std.debug.print(
        "\n🧠 Zero-Day Predictor Analysis\n",
        .{},
    );

    for (events) |e| {

        const score = calculateRisk(e);

        if (score > 0.70) {

            const p = Prediction{
                .software = e.service,
                .risk_score = score,
                .reason = "High exploit probing and anomaly frequency",
            };

            report(p);
        }
    }
}

fn calculateRisk(t: Telemetry) f32 {

    const exploit_factor = @as(f32, @floatFromInt(t.exploit_attempts)) / 100.0;
    const anomaly_factor = @as(f32, @floatFromInt(t.unusual_patterns)) / 50.0;

    var score = exploit_factor + anomaly_factor;

    if (score > 1.0) {
        score = 1.0;
    }

    return score;
}

fn report(p: Prediction) void {

    std.debug.print(
        "\n⚠️ Potential Zero-Day Target Identified\n",
        .{},
    );

    std.debug.print(
        "Software: {s}\n",
        .{p.software},
    );

    std.debug.print(
        "Predicted Risk Score: {d:.2}\n",
        .{p.risk_score},
    );

    std.debug.print(
        "Reason: {s}\n\n",
        .{p.reason},
    );
}