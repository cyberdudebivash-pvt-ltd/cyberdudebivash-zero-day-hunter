const std = @import("std");

pub const CodeSample = struct {
    project: []const u8,
    file: []const u8,
};

pub const VulnPattern = struct {
    pattern: []const u8,
    category: []const u8,
};

pub const VulnerabilityCandidate = struct {
    project: []const u8,
    pattern: []const u8,
    confidence: u8,
};