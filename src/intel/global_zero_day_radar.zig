const std = @import("std");

pub const SoftwareTrend = struct {
    product: []const u8,
    recent_cves: u32,
    exploit_activity: u32,
};

pub fn analyze(trends: []SoftwareTrend) void {

    std.debug.print(
        "\n🚨 CyberDudeBivash Global Zero-Day Radar\n",
        .{},
    );

    for (trends) |t| {

        const risk_score = t.recent_cves * 2 + t.exploit_activity * 3;

        std.debug.print(
            "Analyzing {s} | CVEs: {d} | Exploits: {d}\n",
            .{t.product, t.recent_cves, t.exploit_activity},
        );

        if (risk_score > 20) {

            std.debug.print(
                "⚠ HIGH probability of upcoming zero-day in {s}\n",
                .{t.product},
            );

        } else if (risk_score > 10) {

            std.debug.print(
                "⚠ Medium zero-day risk: {s}\n",
                .{t.product},
            );

        } else {

            std.debug.print(
                "✓ Low risk: {s}\n",
                .{t.product},
            );
        }
    }
}