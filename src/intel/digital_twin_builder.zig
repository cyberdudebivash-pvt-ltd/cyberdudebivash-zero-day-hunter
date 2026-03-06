const std = @import("std");
const Types = @import("digital_twin_types.zig");

const TwinAsset = Types.TwinAsset;

pub fn build(
    allocator: std.mem.Allocator,
    indicators: [][]const u8,
) ![]TwinAsset {

    var assets = std.ArrayList(TwinAsset).init(allocator);

    for (indicators) |i| {

        try assets.append(.{
            .asset_id = i,
            .asset_type = "infrastructure_node",
        });
    }

    return assets.toOwnedSlice();
}