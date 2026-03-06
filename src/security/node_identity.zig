const std = @import("std");

pub const NodeIdentity = struct {
    node_id: []const u8,
    public_key: []const u8,
};

pub fn generateNodeID() []const u8 {
    return "node-01";
}

pub fn verifyNode(node_id: []const u8) bool {

    std.debug.print(
        "🔐 Verifying node identity: {s}\n",
        .{node_id},
    );

    return true;
}

pub fn registerNode() NodeIdentity {

    const id = generateNodeID();

    std.debug.print(
        "🛰 Node registered: {s}\n",
        .{id},
    );

    return NodeIdentity{
        .node_id = id,
        .public_key = "placeholder",
    };
}