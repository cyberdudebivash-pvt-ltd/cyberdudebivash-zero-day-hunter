const std = @import("std");

const InfrastructureModel =
    @import("infrastructure_model.zig").InfrastructureModel;
const AssetNode = @import("asset_node.zig").AssetNode;
const AssetType = @import("asset_node.zig").AssetType;

pub fn buildTwin(
    allocator: std.mem.Allocator,
) !InfrastructureModel {

    var model = InfrastructureModel.init(allocator);

    try model.addAsset(.{
        .id = "web_server_01",
        .asset_type = AssetType.server,
        .hostname = "web.example.com",
    });

    try model.addAsset(.{
        .id = "db_server_01",
        .asset_type = AssetType.database,
        .hostname = "db.internal",
    });

    try model.addAsset(.{
        .id = "api_gateway",
        .asset_type = AssetType.api,
        .hostname = "api.example.com",
    });

    return model;
}