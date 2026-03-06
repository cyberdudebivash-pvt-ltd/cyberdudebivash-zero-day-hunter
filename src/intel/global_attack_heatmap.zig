const std = @import("std");

pub const AttackEvent = struct {
    source_ip: []const u8,
    target: []const u8,
    country: []const u8,
    severity: u8,
    timestamp: i64,
};

pub const CountryStats = struct {
    country: []const u8,
    attacks: usize,
    score: f64,
};

pub const GlobalAttackHeatmap = struct {

    allocator: std.mem.Allocator,

    events: std.ArrayList(AttackEvent),
    countries: std.StringHashMap(CountryStats),

    // ------------------------------------------------
    // INIT
    // ------------------------------------------------
    pub fn init(
        allocator: std.mem.Allocator,
    ) GlobalAttackHeatmap {

        return .{
            .allocator = allocator,
            .events = std.ArrayList(AttackEvent).init(allocator),
            .countries = std.StringHashMap(CountryStats).init(allocator),
        };
    }

    // ------------------------------------------------
    // DEINIT
    // ------------------------------------------------
    pub fn deinit(self: *GlobalAttackHeatmap) void {

        for (self.events.items) |e| {
            self.allocator.free(e.source_ip);
            self.allocator.free(e.target);
            self.allocator.free(e.country);
        }

        self.events.deinit();

        var it = self.countries.iterator();

        while (it.next()) |entry| {
            self.allocator.free(entry.value_ptr.country);
        }

        self.countries.deinit();
    }

    // ------------------------------------------------
    // INGEST ATTACK EVENT
    // ------------------------------------------------
    pub fn addEvent(
        self: *GlobalAttackHeatmap,
        source_ip: []const u8,
        target: []const u8,
        country: []const u8,
        severity: u8,
    ) !void {

        const ip = try self.allocator.dupe(u8, source_ip);
        const tgt = try self.allocator.dupe(u8, target);
        const c = try self.allocator.dupe(u8, country);

        try self.events.append(.{
            .source_ip = ip,
            .target = tgt,
            .country = c,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        });

        try self.updateCountryStats(c, severity);
    }

    // ------------------------------------------------
    // COUNTRY AGGREGATION
    // ------------------------------------------------
    fn updateCountryStats(
        self: *GlobalAttackHeatmap,
        country: []const u8,
        severity: u8,
    ) !void {

        if (self.countries.getPtr(country)) |stats| {

            stats.attacks += 1;
            stats.score += @as(f64, severity);

        } else {

            const dup = try self.allocator.dupe(u8, country);

            try self.countries.put(
                dup,
                .{
                    .country = dup,
                    .attacks = 1,
                    .score = @as(f64, severity),
                },
            );
        }
    }

    // ------------------------------------------------
    // GENERATE HEATMAP
    // ------------------------------------------------
    pub fn generate(self: *GlobalAttackHeatmap) void {

        std.log.warn(
            "[GlobalAttackHeatmap] Generating attack heatmap",
            .{},
        );

        var it = self.countries.iterator();

        while (it.next()) |entry| {

            const stats = entry.value_ptr.*;

            std.log.warn(
                "Country={s} attacks={} score={d}",
                .{ stats.country, stats.attacks, stats.score },
            );
        }
    }

    // ------------------------------------------------
    // TOP ATTACK SOURCES
    // ------------------------------------------------
    pub fn topCountries(
        self: *GlobalAttackHeatmap,
        limit: usize,
    ) void {

        std.log.warn(
            "[GlobalAttackHeatmap] Top attack regions",
            .{},
        );

        var list = std.ArrayList(CountryStats).init(self.allocator);
        defer list.deinit();

        var it = self.countries.iterator();

        while (it.next()) |entry| {
            list.append(entry.value_ptr.*) catch {};
        }

        std.sort.sort(
            CountryStats,
            list.items,
            {},
            struct {
                fn less(_: void, a: CountryStats, b: CountryStats) bool {
                    return a.score > b.score;
                }
            }.less,
        );

        const count = @min(limit, list.items.len);

        for (list.items[0..count]) |stats| {

            std.log.warn(
                "#{d} {s} attacks={} score={d}",
                .{
                    stats.attacks,
                    stats.country,
                    stats.attacks,
                    stats.score,
                },
            );
        }
    }

    // ------------------------------------------------
    // ASCII SOC HEATMAP
    // ------------------------------------------------
    pub fn renderASCII(self: *GlobalAttackHeatmap) void {

        std.log.warn(
            "========= GLOBAL ATTACK HEATMAP =========",
            .{},
        );

        var it = self.countries.iterator();

        while (it.next()) |entry| {

            const stats = entry.value_ptr.*;

            const intensity = @min(stats.attacks, 20);

            var bar: [20]u8 = undefined;

            for (bar[0..intensity]) |*b| {
                b.* = '#';
            }

            for (bar[intensity..]) |*b| {
                b.* = ' ';
            }

            std.log.warn(
                "{s:10} | {s}",
                .{
                    stats.country,
                    bar[0..],
                },
            );
        }
    }

    // ------------------------------------------------
    // CLEAR EVENTS
    // ------------------------------------------------
    pub fn reset(self: *GlobalAttackHeatmap) void {

        for (self.events.items) |e| {
            self.allocator.free(e.source_ip);
            self.allocator.free(e.target);
            self.allocator.free(e.country);
        }

        self.events.clearRetainingCapacity();
    }
};