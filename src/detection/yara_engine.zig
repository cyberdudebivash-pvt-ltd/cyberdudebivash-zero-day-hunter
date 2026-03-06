const std = @import("std");

const YaraLoader = @import("yara_loader.zig");
const Finding = @import("../report/finding.zig").Finding;

pub fn evaluateYara(
    allocator: std.mem.Allocator,
    content: []const u8,
) ![]Finding {

    const rules = try YaraLoader.loadYara(allocator);

    var findings = std.ArrayList(Finding).init(allocator);

    for (rules) |rule| {

        if (std.mem.indexOf(u8, content, rule.pattern) != null) {

            try findings.append(.{
                .hunter = "yara",
                .finding_type = rule.name,
                .severity = "high",
                .description = "YARA malware signature detected",
            });
        }
    }

    return findings.toOwnedSlice();
}