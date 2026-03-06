const std = @import("std");

pub const AttackPattern = struct {
    malware: []const u8,
    vulnerability: []const u8,
    infrastructure: []const u8,
    campaign: []const u8,
};