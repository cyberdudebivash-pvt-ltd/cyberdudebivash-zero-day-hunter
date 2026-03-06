const std = @import("std");

const Builder = @import("digital_twin_builder.zig");
const StateEngine = @import("digital_twin_state_engine.zig");
const Simulator = @import("digital_twin_attack_simulator.zig");
const Risk = @import("digital_twin_risk_estimator.zig");

const Types = @import("digital_twin_types.zig");
const TwinAttack = Types.TwinAttack;

pub fn run(
    allocator: std.mem.Allocator,
    indicators: [][]const u8,
) !void {

    const assets = try Builder.build(allocator, indicators);

    var states = try StateEngine.initialize(allocator, assets);

    const attacks = [_]TwinAttack{
        .{ .source = "external", .target = indicators[0] },
    };

    Simulator.simulate(states, &attacks);

    const risk = Risk.estimate(states);

    std.log.info(
        "digital twin compromised={} risk={}",
        .{ risk.compromised_assets, risk.risk_score },
    );
}