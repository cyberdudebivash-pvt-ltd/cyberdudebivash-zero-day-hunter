const std = @import("std");

const Types = @import("vuln_lab_types.zig");

const VulnerabilityCandidate = Types.VulnerabilityCandidate;

pub fn generate(
    candidates: []VulnerabilityCandidate,
) void {

    for (candidates) |c| {

        if (c.confidence > 60) {

            std.log.warn(
                "vulnerability_candidate project={s} pattern={s}",
                .{ c.project, c.pattern },
            );
        }
    }
}