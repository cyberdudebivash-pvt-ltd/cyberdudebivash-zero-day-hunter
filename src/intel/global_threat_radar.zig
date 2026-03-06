const std = @import("std");

pub const ThreatLevel = enum {
    low,
    medium,
    high,
    critical,
};

pub const RadarSignal = struct {
    region: []const u8,
    source: []const u8,
    severity: ThreatLevel,
};

pub const RadarRegion = struct {
    region: []const u8,
    score: f64,
    level: ThreatLevel,
};

pub const GlobalThreatRadar = struct {

    allocator: std.mem.Allocator,

    signals: std.ArrayList(RadarSignal),

    regions: std.StringHashMap(f64),

    results: std.ArrayList(RadarRegion),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) GlobalThreatRadar {

        return .{
            .allocator = allocator,
            .signals = std.ArrayList(RadarSignal).init(allocator),
            .regions = std.StringHashMap(f64).init(allocator),
            .results = std.ArrayList(RadarRegion).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *GlobalThreatRadar) void {

        for (self.signals.items) |s| {
            self.allocator.free(s.region);
            self.allocator.free(s.source);
        }

        self.signals.deinit();

        var it = self.regions.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
        }

        self.regions.deinit();

        for (self.results.items) |r| {
            self.allocator.free(r.region);
        }

        self.results.deinit();
    }

    // ------------------------------------------------
    // ADD SIGNAL
    // ------------------------------------------------
    pub fn recordSignal(
        self: *GlobalThreatRadar,
        region: []const u8,
        source: []const u8,
        severity: ThreatLevel,
    ) !void {

        const r = try self.allocator.dupe(u8, region);
        const s = try self.allocator.dupe(u8, source);

        try self.signals.append(.{
            .region = r,
            .source = s,
            .severity = severity,
        });

        std.log.info(
            "[ThreatRadar] signal region={s} source={s}",
            .{ r, s },
        );
    }

    // ------------------------------------------------
    // UPDATE REGION SCORES
    // ------------------------------------------------
    fn updateRegionScore(
        self: *GlobalThreatRadar,
        region: []const u8,
        value: f64,
    ) !void {

        if (self.regions.get(region)) |score| {

            try self.regions.put(region, score + value);

        } else {

            const key = try self.allocator.dupe(u8, region);

            try self.regions.put(key, value);
        }
    }

    // ------------------------------------------------
    // ANALYZE SIGNALS
    // ------------------------------------------------
    pub fn analyze(self: *GlobalThreatRadar) !void {

        std.log.info(
            "[ThreatRadar] analyzing global signals",
            .{},
        );

        for (self.signals.items) |sig| {

            const weight: f64 = switch (sig.severity) {
                .low => 0.5,
                .medium => 1.0,
                .high => 2.0,
                .critical => 3.0,
            };

            try self.updateRegionScore(sig.region, weight);
        }

        try self.generateRadar();
    }

    // ------------------------------------------------
    // GENERATE RADAR RESULTS
    // ------------------------------------------------
    fn generateRadar(self: *GlobalThreatRadar) !void {

        var it = self.regions.iterator();

        while (it.next()) |entry| {

            const region = entry.key_ptr.*;
            const score = entry.value_ptr.*;

            const level =
                if (score > 8.0)
                    ThreatLevel.critical
                else if (score > 5.0)
                    ThreatLevel.high
                else if (score > 2.0)
                    ThreatLevel.medium
                else
                    ThreatLevel.low;

            const r = try self.allocator.dupe(u8, region);

            try self.results.append(.{
                .region = r,
                .score = score,
                .level = level,
            });
        }
    }

    // ------------------------------------------------
    // ASCII RADAR DISPLAY
    // ------------------------------------------------
    pub fn render(self: *GlobalThreatRadar) void {

        std.log.warn(
            "========== GLOBAL THREAT RADAR ==========",
            .{},
        );

        for (self.results.items) |r| {

            const bars = @intFromFloat(r.score);

            var i: usize = 0;

            std.log.warn("{s}  ", .{ r.region });

            while (i < bars) : (i += 1) {
                std.debug.print("█", .{});
            }

            std.debug.print(
                "  level={}\n",
                .{ r.level },
            );
        }
    }

    // ------------------------------------------------
    // REPORT
    // ------------------------------------------------
    pub fn report(self: *GlobalThreatRadar) void {

        std.log.warn(
            "===== Global Threat Radar Report =====",
            .{},
        );

        for (self.results.items) |r| {

            std.log.warn(
                "Region={s} Score={d} Level={}",
                .{
                    r.region,
                    r.score,
                    r.level,
                },
            );
        }
    }

    // ------------------------------------------------
    // RESET
    // ------------------------------------------------
    pub fn reset(self: *GlobalThreatRadar) void {

        for (self.signals.items) |s| {
            self.allocator.free(s.region);
            self.allocator.free(s.source);
        }

        self.signals.clearRetainingCapacity();

        for (self.results.items) |r| {
            self.allocator.free(r.region);
        }

        self.results.clearRetainingCapacity();

        self.regions.clearRetainingCapacity();
    }
};