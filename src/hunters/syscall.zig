const std = @import("std");
const Hunter = @import("../core/interface.zig").Hunter;

pub fn run() !void {
    std.debug.print(
        "⚔️ Syscall Tracing — Detecting ROP & LoTL\n",
        .{},
    );
}

pub const plugin = Hunter{
    .name = "syscall",
    .run = run,
};