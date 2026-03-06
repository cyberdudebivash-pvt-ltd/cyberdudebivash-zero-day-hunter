const std = @import("std");

pub const CampaignSignal = struct {
    target: []const u8,
    issue: []const u8,
    hunter: []const u8,
    confidence: u8,
};

pub const ThreatCampaign = struct {
    campaign_id: []const u8,
    signal_count: u32,
    avg_confidence: u8,
    threat_level: []const u8,
};