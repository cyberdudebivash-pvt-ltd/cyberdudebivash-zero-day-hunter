const std = @import("std");

pub const DarkWebSignal = struct {
    source: []const u8,
    category: []const u8,
    indicator: []const u8,
    confidence: u8,
};

pub const LeakRecord = struct {
    target: []const u8,
    dataset: []const u8,
};

pub const ExploitMention = struct {
    vulnerability: []const u8,
    chatter_score: u8,
};

pub const RansomwareSignal = struct {
    group: []const u8,
    victim: []const u8,
};

pub const CredentialLeak = struct {
    domain: []const u8,
    record_count: u32,
};