const std = @import("std");

pub const AssetType = enum {
    server,
    database,
    cloud_instance,
    api,
    user_account,
};

pub const AssetNode = struct {
    id: []const u8,
    asset_type: AssetType,
    hostname: []const u8,
};