const std = @import("std");

const SigmaLoader = @import("sigma_loader.zig");
const Finding = @import("../report/finding.zig").Finding;

pub fn evaluateSigma(
    allocator: std.mem.Allocator,
    event: []const u8,
) ![]Finding {

    const rules = try SigmaLoader.loadSigma(allocator);

    var findings = std.ArrayList(Finding).init(allocator);

    for (rules) |rule| {

        if (std.mem.indexOf(u8, event, rule.detection) != null) {

            try findings.append(.{
                .hunter = "sigma",
                .finding_type = rule.title,
                .severity = rule.severity,
                .description = "Sigma rule triggered",
            });
        }
    }

    return findings.toOwnedSlice();
}