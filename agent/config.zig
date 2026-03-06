const std = @import("std");

pub const Config = struct {
    node_id: []const u8 = "CDB-NODE-IND-01",
    api_url: []const u8 = "http://localhost:8080",
    poll_interval: u64 = 10,
};