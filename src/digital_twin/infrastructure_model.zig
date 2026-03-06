const std = @import("std");
const AssetNode = @import("asset_node.zig").AssetNode;

pub const InfrastructureModel = struct {
    assets: std.ArrayList(AssetNode),

    pub fn init(allocator: std.mem.Allocator) InfrastructureModel {
        return InfrastructureModel{
            .assets = std.ArrayList(AssetNode).init(allocator),
        };
    }

    pub fn addAsset(self: *InfrastructureModel, asset: AssetNode) !void {
        try self.assets.append(asset);
    }
};