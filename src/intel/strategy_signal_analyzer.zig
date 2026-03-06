const std = @import("std");
const Types = @import("strategy_types.zig");

const StrategySignal = Types.StrategySignal;

pub fn analyze(signals: []StrategySignal) u32 {

    var high_risk: u32 = 0;

    for (signals) |s| {

        if (s.confidence > 70)
            high_risk += 1;
    }

    return high_risk;
}