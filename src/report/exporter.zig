const std = @import("std");

const Report = @import("report_builder.zig").Report;

pub fn exportReport(
    allocator: std.mem.Allocator,
    report: Report,
) !void {

    // Ensure reports directory exists
    std.fs.cwd().makePath("reports") catch {};

    const file = try std.fs.cwd().createFile(
        "reports/report.json",
        .{},
    );
    defer file.close();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    const writer = buffer.writer();

    try writer.writeAll("{\n");

    try writer.print(
        "  \"target\": \"{s}\",\n",
        .{report.target},
    );

    try writer.print(
        "  \"generated_at\": {},\n",
        .{report.generated_at},
    );

    try writer.writeAll("  \"findings\": [\n");

    for (report.findings, 0..) |finding, i| {

        try writer.writeAll("    {\n");

        try writer.print(
            "      \"hunter\": \"{s}\",\n",
            .{finding.hunter},
        );

        try writer.print(
            "      \"type\": \"{s}\",\n",
            .{finding.finding_type},
        );

        try writer.print(
            "      \"severity\": \"{s}\",\n",
            .{finding.severity},
        );

        try writer.print(
            "      \"description\": \"{s}\"\n",
            .{finding.description},
        );

        try writer.writeAll("    }");

        if (i + 1 < report.findings.len)
            try writer.writeAll(",");

        try writer.writeAll("\n");
    }

    try writer.writeAll("  ]\n");
    try writer.writeAll("}\n");

    try file.writeAll(buffer.items);

    std.log.info("Report exported to reports/report.json", .{});
}