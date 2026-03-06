const std = @import("std");

const IOC = @import("defense_ioc_blocker.zig");
const Botnet = @import("defense_botnet_blacklist.zig");
const Exploit = @import("defense_exploit_mitigator.zig");
const Patch = @import("defense_patch_advisor.zig");

const Types = @import("defense_types.zig");
const DefenseSignal = Types.DefenseSignal;

pub fn orchestrate(
    allocator: std.mem.Allocator,
    signals: []DefenseSignal,
) !void {

    const ioc_actions = try IOC.generate(allocator, signals);
    const botnet_actions = try Botnet.recommend(allocator, signals);
    const exploit_actions = try Exploit.mitigate(allocator, signals);
    const patch_actions = try Patch.recommend_patch(allocator, signals);

    std.log.info(
        "defense actions: ioc={} botnet={} exploit={} patch={}",
        .{
            ioc_actions.len,
            botnet_actions.len,
            exploit_actions.len,
            patch_actions.len,
        },
    );
}