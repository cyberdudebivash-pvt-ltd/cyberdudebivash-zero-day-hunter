const std = @import("std");

const intel_store = @import("../api/intel_store.zig");
const Finding = @import("../hunters/interface.zig").Finding;

/// Enriched intelligence record
pub const IntelIndicator = struct {
    indicator: []const u8,
    category: []const u8,
    severity: []const u8,
};

pub const FusionConfig = struct {
    enable_indicator_match: bool = true,
    enable_threat_scoring: bool = true,
};

pub const ThreatIntelFusion = struct {
    allocator: std.mem.Allocator,
    config: FusionConfig,

    pub fn init(
        allocator: std.mem.Allocator,
        config: FusionConfig,
    ) ThreatIntelFusion {
        return ThreatIntelFusion{
            .allocator = allocator,
            .config = config,
        };
    }

    /// Main enrichment entrypoint
    pub fn enrich(
        self: *ThreatIntelFusion,
        findings: *std.ArrayList(Finding),
    ) !void {

        std.log.info("Threat intel fusion started", .{});

        const indicators = try loadIndicators(self.allocator);

        if (indicators.items.len == 0) {
            std.log.warn("No intel indicators available", .{});
            return;
        }

        for (findings.items) |*finding| {

            if (self.config.enable_indicator_match) {
                correlateIndicators(finding, indicators.items);
            }

            if (self.config.enable_threat_scoring) {
                applyThreatScore(finding);
            }
        }

        std.log.info("Threat intel enrichment completed", .{});
    }
};

/// Load indicators from intel store
fn loadIndicators(
    allocator: std.mem.Allocator,
) !std.ArrayList(IntelIndicator) {

    std.log.info("Loading threat indicators", .{});

    var indicators = std.ArrayList(IntelIndicator).init(allocator);

    const events = intel_store.getAll() catch {
        std.log.warn("Intel store unavailable", .{});
        return indicators;
    };

    for (events) |event| {
        try indicators.append(IntelIndicator{
            .indicator = event.indicator,
            .category = event.category,
            .severity = event.severity,
        });
    }

    std.log.info("Indicators loaded: {}", .{indicators.items.len});

    return indicators;
}

/// Correlate findings with intel indicators
fn correlateIndicators(
    finding: *Finding,
    indicators: []IntelIndicator,
) void {

    for (indicators) |indicator| {

        if (std.mem.indexOf(u8, finding.description, indicator.indicator) != null) {

            std.log.info(
                "Intel match: {s} → finding {s}",
                .{ indicator.indicator, finding.finding_type },
            );

            finding.severity = indicator.severity;
        }
    }
}

/// Calculate threat score and adjust severity
fn applyThreatScore(finding: *Finding) void {

    if (std.mem.eql(u8, finding.severity, "critical")) return;

    if (std.mem.eql(u8, finding.severity, "high")) return;

    if (std.mem.eql(u8, finding.severity, "medium")) {
        finding.severity = "high";
    }
}