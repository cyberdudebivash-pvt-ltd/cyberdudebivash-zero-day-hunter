const std = @import("std");

const BreachScenario = @import("threat_simulation_types.zig").BreachScenario;
const BlastRadius = @import("threat_simulation_types.zig").BlastRadius;

pub fn estimate(
    scenarios: []BreachScenario,
) BlastRadius {

    var total: u32 = 0;

    for (scenarios) |s| {
        total += s.affected_nodes;
    }

    const severity: u8 =
        if (total > 20) 90
        else if (total > 10) 70
        else 40;

    return BlastRadius{
        .compromised_assets = total,
        .severity = severity,
    };
}