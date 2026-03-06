const std = @import("std");

pub const ThreatSignal = struct {
    indicator: []const u8,
    exploit_activity: usize,
    malware_reports: usize,
    darkweb_mentions: usize,
};

pub const Prediction = struct {
    indicator: []const u8,
    probability: f32,
};

pub fn analyze(signals: []const ThreatSignal) void {

    std.debug.print(
        "\n🤖 AI Threat Prediction Engine\n",
        .{},
    );

    for (signals) |s| {

        const probability = calculateProbability(s);

        std.debug.print(
            "\nIndicator: {s}\n",
            .{s.indicator},
        );

        std.debug.print(
            "Predicted Attack Probability: {d:.2}\n",
            .{probability},
        );

        if (probability > 0.75) {

            std.debug.print(
                "🚨 High likelihood of active exploitation\n",
                .{},
            );
        }
    }
}

fn calculateProbability(s: ThreatSignal) f32 {

    const exploit_weight: f32 = 0.4;
    const malware_weight: f32 = 0.3;
    const darkweb_weight: f32 = 0.3;

    const exploit_score =
        @as(f32, @floatFromInt(s.exploit_activity)) / 100.0;

    const malware_score =
        @as(f32, @floatFromInt(s.malware_reports)) / 50.0;

    const darkweb_score =
        @as(f32, @floatFromInt(s.darkweb_mentions)) / 20.0;

    var probability =
        exploit_score * exploit_weight +
        malware_score * malware_weight +
        darkweb_score * darkweb_weight;

    if (probability > 1.0) {
        probability = 1.0;
    }

    return probability;
}