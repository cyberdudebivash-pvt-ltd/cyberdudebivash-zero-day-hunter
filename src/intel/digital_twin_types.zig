const std = @import("std");

pub const TwinAsset = struct {
    asset_id: []const u8,
    asset_type: []const u8,
};

pub const TwinState = struct {
    asset_id: []const u8,
    compromised: bool,
};

pub const TwinAttack = struct {
    source: []const u8,
    target: []const u8,
};

pub const TwinRisk = struct {
    compromised_assets: u32,
    risk_score: u8,
};