const std = @import("std");

const Analyzer = @import("strategy_signal_analyzer.zig");
const RiskModel = @import("strategy_risk_model.zig");
const Generator = @import("strategy_generator.zig");

const Types = @import("strategy_types.zig");
const StrategySignal = Types.StrategySignal;

pub fn run(
    allocator: std.mem.Allocator,
    signals: []StrategySignal,
) !void {

    const high_risk = Analyzer.analyze(signals);

    const risk = RiskModel.calculate(high_risk);

    const strategies = try Generator.generate(allocator, risk.risk_level);

    for (strategies) |s| {

        std.log.info(
            "recommended_strategy={} priority={}",
            .{ s.strategy, s.priority },
        );
    }
}