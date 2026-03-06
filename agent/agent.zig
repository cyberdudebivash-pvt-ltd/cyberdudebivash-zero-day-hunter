const std = @import("std");
const Config = @import("config.zig").Config;
const report = @import("report.zig");

pub fn runAgent() !void {

    while (true) {

        std.debug.print("📡 Requesting task from control plane...\n", .{});

        const task = try fetchTask();

        if (task) |target| {

            std.debug.print("🎯 Task received: {s}\n", .{target});

            const findings = try runHunters(target);

            try uploadFindings(target, findings);

        } else {
            std.debug.print("No tasks available\n", .{});
        }

        std.time.sleep(Config.poll_interval * std.time.ns_per_s);
    }
}

fn fetchTask() !?[]const u8 {

    // simplified example
    return "example.com";
}

fn runHunters(target: []const u8) ![]const u8 {

    std.debug.print("Running hunters for {s}\n", .{target});

    return report.generate(target);
}

fn uploadFindings(target: []const u8, findings: []const u8) !void {

    std.debug.print("Uploading findings for {s}\n", .{target});
    std.debug.print("{s}\n", .{findings});
}