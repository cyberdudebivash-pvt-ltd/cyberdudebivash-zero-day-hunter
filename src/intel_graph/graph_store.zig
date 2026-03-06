const std = @import("std");

const GraphNode = @import("graph_types.zig").GraphNode;
const GraphEdge = @import("graph_types.zig").GraphEdge;

pub const GraphStore = struct {

    nodes: std.ArrayList(GraphNode),
    edges: std.ArrayList(GraphEdge),

    pub fn init(allocator: std.mem.Allocator) GraphStore {
        return GraphStore{
            .nodes = std.ArrayList(GraphNode).init(allocator),
            .edges = std.ArrayList(GraphEdge).init(allocator),
        };
    }

    pub fn addNode(self: *GraphStore, node: GraphNode) !void {
        try self.nodes.append(node);
    }

    pub fn addEdge(self: *GraphStore, edge: GraphEdge) !void {
        try self.edges.append(edge);
    }
};