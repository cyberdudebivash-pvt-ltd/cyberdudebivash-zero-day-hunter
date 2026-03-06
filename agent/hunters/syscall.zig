const std = @import("std");

pub fn hunt(target: []const u8) !void {
    std.debug.print("⚔️ Syscall tracing {s}\n", .{target});
}