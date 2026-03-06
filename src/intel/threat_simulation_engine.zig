const std = @import("std");

const PathGen = @import("threat_path_generator.zig");
const Breach = @import("threat_breach_simulator.zig");
const Radius = @import("threat_blast_radius.zig");

const KG = @import("knowledge_graph_types.zig");

pub fn run(
    allocator: std.mem.Allocator,
    graph: KG.KnowledgeGraph,
) !void {

    const paths = try PathGen.generate_paths(allocator, graph);

    const scenarios = try Breach.simulate(allocator, paths);

    const blast = Radius.estimate(scenarios);

    std.log.info(
        "threat simulation paths={} compromised_assets={} severity={}",
        .{ paths.len, blast.compromised_assets, blast.severity },
    );
}