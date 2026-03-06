const std = @import("std");

pub const AttackVector = struct {
    entry_point: []const u8,
    vulnerability: []const u8,
    technique: []const u8,
};