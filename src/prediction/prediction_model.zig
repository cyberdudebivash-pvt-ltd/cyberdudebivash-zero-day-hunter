const std = @import("std");

const AttackPattern = @import("attack_pattern.zig").AttackPattern;

pub fn predict(
    event: []const u8,
) ?AttackPattern {

    if (std.mem.indexOf(u8, event, "169.254.169.254") != null) {

        return AttackPattern{
            .malware = "CloudStealer",
            .vulnerability = "Cloud Metadata Exposure",
            .infrastructure = "169.254.169.254",
            .campaign = "CloudHarvest Campaign",
        };
    }

    return null;
}