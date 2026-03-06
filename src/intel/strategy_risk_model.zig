const std = @import("std");
const Types = @import("strategy_types.zig");

const StrategyRisk = Types.StrategyRisk;

pub fn calculate(high_risk_signals: u32) StrategyRisk {

    const level: u8 =
        if (high_risk_signals > 20) 90
        else if (high_risk_signals > 10) 70
        else 40;

    return StrategyRisk{
        .risk_level = level,
    };
}