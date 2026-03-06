const std = @import("std");

const Types = @import("vuln_lab_types.zig");

const CodeSample = Types.CodeSample;
const VulnPattern = Types.VulnPattern;
const VulnerabilityCandidate = Types.VulnerabilityCandidate;

pub fn analyze(
    allocator: std.mem.Allocator,
    samples: []CodeSample,
    patterns: []const VulnPattern,
) ![]VulnerabilityCandidate {

    var results = std.ArrayList(VulnerabilityCandidate).init(allocator);

    for (samples) |s| {

        for (patterns) |p| {

            try results.append(.{
                .project = s.project,
                .pattern = p.pattern,
                .confidence = 70,
            });
        }
    }

    return results.toOwnedSlice();
}