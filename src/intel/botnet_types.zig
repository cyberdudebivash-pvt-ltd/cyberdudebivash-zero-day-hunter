const std = @import("std");

pub const BotSignal = struct {
    source_ip: []const u8,
    target: []const u8,
    issue: []const u8,
    confidence: u8,
};

pub const BotNode = struct {
    ip: []const u8,
    activity_count: u32,
    avg_confidence: u8,
};

pub const BotCluster = struct {
    cluster_id: []const u8,
    node_count: u32,
    activity_score: u8,
};

pub const C2Candidate = struct {
    controller: []const u8,
    bot_count: u32,
    risk_score: u8,
};

pub const BotnetMap = struct {
    nodes: []BotNode,
    clusters: []BotCluster,
    c2_servers: []C2Candidate,
};