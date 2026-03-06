const std = @import("std");

const GraphStore = @import("graph_store.zig").GraphStore;
const GraphNode = @import("graph_types.zig").GraphNode;
const GraphNodeType = @import("graph_types.zig").GraphNodeType;
const Linker = @import("graph_linker.zig");

pub fn buildGraph(
    allocator: std.mem.Allocator,
) !void {

    var store = GraphStore.init(allocator);

    try store.addNode(.{
        .id = "malware_rustbot",
        .node_type = GraphNodeType.malware,
        .name = "RustBot",
    });

    try store.addNode(.{
        .id = "infra_185.220.101.1",
        .node_type = GraphNodeType.infrastructure,
        .name = "185.220.101.1",
    });

    try Linker.link(
        &store,
        "malware_rustbot",
        "infra_185.220.101.1",
        "uses",
    );

    std.log.info(
        "CyberDudeBivash Threat Intelligence Graph initialized",
        .{},
    );
}