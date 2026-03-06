const std = @import("std");

pub const Node = struct {
    name: []const u8,
};

pub const Edge = struct {
    from: []const u8,
    to: []const u8,
};

pub const AttackGraph = struct {
    nodes: std.ArrayList(Node),
    edges: std.ArrayList(Edge),
};

pub fn simulate(graph: *AttackGraph, start: []const u8) void {

    std.debug.print(
        "\n🧠 Attack Path Simulation starting from: {s}\n",
        .{start},
    );

    for (graph.edges.items) |edge| {

        if (std.mem.eql(u8, edge.from, start)) {

            std.debug.print(
                "⚠ Potential lateral movement: {s} → {s}\n",
                .{edge.from, edge.to},
            );

            recursiveExplore(graph, edge.to, 1);
        }
    }
}

fn recursiveExplore(graph: *AttackGraph, current: []const u8, depth: u8) void {

    if (depth > 5) return;

    for (graph.edges.items) |edge| {

        if (std.mem.eql(u8, edge.from, current)) {

            std.debug.print(
                "↳ Step {d}: {s} → {s}\n",
                .{depth, edge.from, edge.to},
            );

            recursiveExplore(graph, edge.to, depth + 1);
        }
    }
}