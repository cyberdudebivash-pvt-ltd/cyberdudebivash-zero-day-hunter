const std = @import("std");

pub const Severity = enum {
    info,
    low,
    medium,
    high,
    critical,
};

pub const HunterResult = struct {
    detected: bool,
    severity: Severity,
    title: []const u8,
    description: []const u8,
    evidence: []const u8,

    pub fn clean(self: *HunterResult, allocator: std.mem.Allocator) void {
        allocator.free(self.title);
        allocator.free(self.description);
        allocator.free(self.evidence);
    }
};

/// Runtime-safe hunter execution function pointer
pub const RunFn = *const fn (
    allocator: std.mem.Allocator,
    target: []const u8,
) anyerror!HunterResult;

/// Main interface every hunter must implement
pub const HunterInterface = struct {

    /// Unique hunter identifier
    name: []const u8,

    /// Human readable description
    description: []const u8,

    /// Category of detection
    category: []const u8,

    /// Version of the hunter module
    version: []const u8,

    /// Execution entrypoint
    run: RunFn,

    /// Execute the hunter
    pub fn execute(
        self: *const HunterInterface,
        allocator: std.mem.Allocator,
        target: []const u8,
    ) !HunterResult {

        if (self.run == null) {
            return error.InvalidHunter;
        }

        return self.run(allocator, target);
    }
};