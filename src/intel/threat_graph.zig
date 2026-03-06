const std = @import("std");

pub const NodeType = enum {
    ip,
    domain,
    vulnerability,
    exploit,
};

pub const Node = struct {
    id: []const u8,
    node_type: NodeType,
};

pub const Edge = struct {
    from: []const u8,
    to: []const u8,
    relation: []const u8,
};

pub const ThreatGraph = struct {
    nodes: std.ArrayList(Node),
    edges: std.ArrayList(Edge),
};

pub fn initGraph(allocator: std.mem.Allocator) ThreatGraph {

    return ThreatGraph{
        .nodes = std.ArrayList(Node).init(allocator),
        .edges = std.ArrayList(Edge).init(allocator),
    };
}

pub fn addNode(
    graph: *ThreatGraph,
    id: []const u8,
    node_type: NodeType,
) !void {

    try graph.nodes.append(.{
        .id = id,
        .node_type = node_type,
    });

    std.debug.print(
        "🧩 Graph node added: {s}\n",
        .{id},
    );
}

pub fn addEdge(
    graph: *ThreatGraph,
    from: []const u8,
    to: []const u8,
    relation: []const u8,
) !void {

    try graph.edges.append(.{
        .from = from,
        .to = to,
        .relation = relation,
    });

    std.debug.print(
        "🔗 Graph relation: {s} -> {s} ({s})\n",
        .{ from, to, relation },
    );
}

pub fn printGraph(graph: *ThreatGraph) void {

    std.debug.print(
        "\n📊 Threat Intelligence Graph\n",
        .{},
    );

    std.debug.print(
        "\nNodes:\n",
        .{},
    );

    for (graph.nodes.items) |n| {

        std.debug.print(
            "- {s}\n",
            .{n.id},
        );
    }

    std.debug.print(
        "\nRelations:\n",
        .{},
    );

    for (graph.edges.items) |e| {

        std.debug.print(
            "{s} --{s}--> {s}\n",
            .{ e.from, e.relation, e.to },
        );
    }
}

pub fn exampleGraph() !void {

    var graph = initGraph(std.heap.page_allocator);

    try addNode(&graph, "192.168.1.10", .ip);
    try addNode(&graph, "api.example.com", .domain);
    try addNode(&graph, "CVE-2021-41773", .vulnerability);
    try addNode(&graph, "ExploitDB-50383", .exploit);

    try addEdge(
        &graph,
        "192.168.1.10",
        "api.example.com",
        "hosts",
    );

    try addEdge(
        &graph,
        "api.example.com",
        "CVE-2021-41773",
        "vulnerable_to",
    );

    try addEdge(
        &graph,
        "CVE-2021-41773",
        "ExploitDB-50383",
        "exploited_by",
    );

    printGraph(&graph);
}