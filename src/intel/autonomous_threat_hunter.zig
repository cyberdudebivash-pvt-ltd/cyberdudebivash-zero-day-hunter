const std = @import("std");

pub const TelemetryEvent = struct {
    source_ip: []const u8,
    service: []const u8,
    indicator: []const u8,
};

pub const DetectionIdea = struct {
    rule_name: []const u8,
    indicator: []const u8,
    confidence: f32,
};

pub fn analyze(events: []const TelemetryEvent) void {

    std.debug.print(
        "\n🧠 Autonomous Threat Hunter — anomaly analysis\n",
        .{},
    );

    var suspicious: usize = 0;

    for (events) |e| {

        if (isSuspicious(e.indicator)) {

            suspicious += 1;

            std.debug.print(
                "⚠️ Suspicious indicator observed: {s}\n",
                .{e.indicator},
            );

            const idea = generateRule(e);

            printIdea(idea);
        }
    }

    if (suspicious == 0) {

        std.debug.print(
            "ℹ️ No anomalies detected\n",
            .{},
        );
    }
}

fn isSuspicious(indicator: []const u8) bool {

    const patterns = [_][]const u8{
        "loader",
        "backdoor",
        "crypto_miner",
        "shell_exec",
        "reverse_tcp",
    };

    for (patterns) |p| {

        if (std.mem.containsAtLeast(u8, indicator, 1, p)) {
            return true;
        }
    }

    return false;
}

fn generateRule(event: TelemetryEvent) DetectionIdea {

    return DetectionIdea{
        .rule_name = "auto_rule_" ++ event.indicator,
        .indicator = event.indicator,
        .confidence = 0.72,
    };
}

fn printIdea(idea: DetectionIdea) void {

    std.debug.print(
        "\n🔬 Candidate Detection Rule\n",
        .{},
    );

    std.debug.print(
        "Rule Name: {s}\n",
        .{idea.rule_name},
    );

    std.debug.print(
        "Indicator: {s}\n",
        .{idea.indicator},
    );

    std.debug.print(
        "Confidence: {d:.2}\n\n",
        .{idea.confidence},
    );
}