const std = @import("std");

const StrategyInput = @import("strategy_input.zig").StrategyInput;

pub fn analyze(
    input: StrategyInput,
) []const u8 {

    if (std.mem.eql(u8, input.threat_level, "high")) {

        return "Immediate infrastructure blocking and rule deployment recommended";
    }

    if (std.mem.eql(u8, input.threat_level, "medium")) {

        return "Increase monitoring and deploy detection rules";
    }

    return "Standard monitoring recommended";
}