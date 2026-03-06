const std = @import("std");

pub const Vulnerability = struct {
    cve: []const u8,
    product: []const u8,
    severity: u8,
};

pub fn recommendPatch(vuln: Vulnerability) void {

    std.debug.print(
        "\n🛠 Autonomous Patch Recommendation\n",
        .{},
    );

    std.debug.print(
        "Vulnerability: {s}\n",
        .{vuln.cve},
    );

    if (vuln.severity >= 9) {

        std.debug.print(
            "⚠ CRITICAL vulnerability detected\n",
            .{},
        );

        std.debug.print(
            "Recommendation: Immediate patch deployment\n",
            .{},
        );

    } else if (vuln.severity >= 7) {

        std.debug.print(
            "⚠ HIGH severity vulnerability\n",
            .{},
        );

        std.debug.print(
            "Recommendation: Patch within 24 hours\n",
            .{},
        );

    } else {

        std.debug.print(
            "ℹ Moderate vulnerability\n",
            .{},
        );

        std.debug.print(
            "Recommendation: Schedule patch in maintenance window\n",
            .{},
        );
    }

    std.debug.print(
        "Target product: {s}\n",
        .{vuln.product},
    );
}