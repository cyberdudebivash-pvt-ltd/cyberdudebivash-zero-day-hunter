const std = @import("std");

const intel_store = @import("../api/intel_store.zig");

/// Intel event structure
pub const IntelEvent = struct {
    source: []const u8,
    indicator: []const u8,
    category: []const u8,
    severity: []const u8,
    timestamp: i64,
};

pub const IntelCollectorConfig = struct {
    enable_cve_feed: bool = true,
    enable_darkweb: bool = false,
    enable_global_signals: bool = true,
};

pub const IntelCollector = struct {
    allocator: std.mem.Allocator,
    config: IntelCollectorConfig,

    pub fn init(
        allocator: std.mem.Allocator,
        config: IntelCollectorConfig,
    ) IntelCollector {

        return IntelCollector{
            .allocator = allocator,
            .config = config,
        };
    }

    /// Entry point used by engine
    pub fn collect(self: *IntelCollector) !void {

        std.log.info("Intel collector started", .{});

        if (self.config.enable_cve_feed) {
            try self.collectCVE();
        }

        if (self.config.enable_darkweb) {
            try self.collectDarkweb();
        }

        if (self.config.enable_global_signals) {
            try self.collectGlobalSignals();
        }

        std.log.info("Intel collection completed", .{});
    }

    fn collectCVE(self: *IntelCollector) !void {

        std.log.info("Collecting CVE intelligence", .{});

        const event = IntelEvent{
            .source = "CVE_FEED",
            .indicator = "CVE-2025-0001",
            .category = "vulnerability",
            .severity = "high",
            .timestamp = std.time.timestamp(),
        };

        try storeEvent(self.allocator, event);
    }

    fn collectDarkweb(self: *IntelCollector) !void {

        std.log.info("Collecting dark web intelligence", .{});

        const event = IntelEvent{
            .source = "DARKWEB_MONITOR",
            .indicator = "credential_leak",
            .category = "data_leak",
            .severity = "critical",
            .timestamp = std.time.timestamp(),
        };

        try storeEvent(self.allocator, event);
    }

    fn collectGlobalSignals(self: *IntelCollector) !void {

        std.log.info("Collecting global threat signals", .{});

        const event = IntelEvent{
            .source = "GLOBAL_SENSOR_NETWORK",
            .indicator = "botnet_activity",
            .category = "botnet",
            .severity = "medium",
            .timestamp = std.time.timestamp(),
        };

        try storeEvent(self.allocator, event);
    }
};

/// Store event safely in intel store
fn storeEvent(
    allocator: std.mem.Allocator,
    event: IntelEvent,
) !void {

    intel_store.store(event) catch |err| {
        std.log.err("Failed to store intel event: {}", .{err});
    };
}