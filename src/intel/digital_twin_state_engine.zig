const std = @import("std");
const Types = @import("digital_twin_types.zig");

const TwinAsset = Types.TwinAsset;
const TwinState = Types.TwinState;

pub fn initialize(
    allocator: std.mem.Allocator,
    assets: []TwinAsset,
) ![]TwinState {

    var states = std.ArrayList(TwinState).init(allocator);

    for (assets) |a| {

        try states.append(.{
            .asset_id = a.asset_id,
            .compromised = false,
        });
    }

    return states.toOwnedSlice();
}