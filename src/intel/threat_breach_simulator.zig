const std = @import("std");

const AttackPath = @import("threat_simulation_types.zig").AttackPath;
const BreachScenario = @import("threat_simulation_types.zig").BreachScenario;

pub fn simulate(
    allocator: std.mem.Allocator,
    paths: []AttackPath,
) ![]BreachScenario {

    var list = std.ArrayList(BreachScenario).init(allocator);

    for (paths) |p| {

        try list.append(.{
            .entry_point = p.entry,
            .affected_nodes = p.steps + 1,
        });
    }

    return list.toOwnedSlice();
}