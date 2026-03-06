const std = @import("std");

const Finding = @import("finding.zig").Finding;
const exporter = @import("exporter.zig");

pub const Report = struct {
    target: []const u8,
    findings: []const Finding,
    generated_at: i64,
};

/// Root-level API used by main.zig
pub fn generate(
    allocator: std.mem.Allocator,
    target: []const u8,
    findings: []const Finding,
) !void {

    std.log.info("Building report for target: {s}", .{target});

    const report = Report{
        .target = target,
        .findings = findings,
        .generated_at = std.time.timestamp(),
    };

    try exporter.exportReport(allocator, report);

    std.log.info("Report generated successfully", .{});
}