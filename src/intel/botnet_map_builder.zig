const std = @import("std");
const Types = @import("botnet_types.zig");

const BotNode = Types.BotNode;
const BotCluster = Types.BotCluster;
const C2Candidate = Types.C2Candidate;
const BotnetMap = Types.BotnetMap;

pub fn build_map(
    allocator: std.mem.Allocator,
    nodes: []BotNode,
    clusters: []BotCluster,
    c2_servers: []C2Candidate,
) BotnetMap {

    _ = allocator;

    return BotnetMap{
        .nodes = nodes,
        .clusters = clusters,
        .c2_servers = c2_servers,
    };
}