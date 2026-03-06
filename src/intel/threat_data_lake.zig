const std = @import("std");

/// Stored intelligence record
pub const ThreatRecord = struct {
    source: []const u8,
    target: []const u8,
    indicator: []const u8,
    severity: u8,
    timestamp: i64,
};

/// Threat Intelligence Data Lake
pub const ThreatDataLake = struct {

    allocator: std.mem.Allocator,

    records: std.ArrayList(ThreatRecord),

    index_by_target: std.StringHashMap(std.ArrayList(usize)),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) ThreatDataLake {

        return .{
            .allocator = allocator,
            .records = std.ArrayList(ThreatRecord).init(allocator),
            .index_by_target = std.StringHashMap(std.ArrayList(usize)).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *ThreatDataLake) void {

        for (self.records.items) |record| {

            self.allocator.free(record.source);
            self.allocator.free(record.target);
            self.allocator.free(record.indicator);
        }

        var it = self.index_by_target.iterator();

        while (it.next()) |entry| {

            entry.value_ptr.deinit();
        }

        self.records.deinit();
        self.index_by_target.deinit();
    }

    /// ------------------------------------------------
    /// ADD RECORD
    /// ------------------------------------------------
    pub fn addRecord(
        self: *ThreatDataLake,
        source: []const u8,
        target: []const u8,
        indicator: []const u8,
        severity: u8,
    ) !void {

        const src = try self.allocator.dupe(u8, source);
        const tgt = try self.allocator.dupe(u8, target);
        const ind = try self.allocator.dupe(u8, indicator);

        const record = ThreatRecord{
            .source = src,
            .target = tgt,
            .indicator = ind,
            .severity = severity,
            .timestamp = std.time.timestamp(),
        };

        const index = self.records.items.len;

        try self.records.append(record);

        if (self.index_by_target.get(tgt)) |*list| {

            try list.append(index);

        } else {

            var list = std.ArrayList(usize).init(self.allocator);
            try list.append(index);

            try self.index_by_target.put(tgt, list);
        }

        std.log.info(
            "[ThreatDataLake] Record stored target={s}",
            .{tgt},
        );
    }

    /// ------------------------------------------------
    /// QUERY TARGET
    /// ------------------------------------------------
    pub fn queryTarget(
        self: *ThreatDataLake,
        target: []const u8,
    ) void {

        std.log.warn(
            "[ThreatDataLake] Query target={s}",
            .{target},
        );

        if (self.index_by_target.get(target)) |list| {

            for (list.items) |record_index| {

                const record = self.records.items[record_index];

                std.log.info(
                    "source={s} indicator={s} severity={}",
                    .{
                        record.source,
                        record.indicator,
                        record.severity,
                    },
                );
            }

        } else {

            std.log.warn(
                "No records found for {s}",
                .{target},
            );
        }
    }

    /// ------------------------------------------------
    /// SEVERITY ANALYTICS
    /// ------------------------------------------------
    pub fn analyzeSeverity(self: *ThreatDataLake) void {

        var critical: usize = 0;
        var high: usize = 0;

        for (self.records.items) |record| {

            if (record.severity >= 80) {
                critical += 1;
            } else if (record.severity >= 50) {
                high += 1;
            }
        }

        std.log.warn(
            "[ThreatDataLake] Severity analytics critical={} high={}",
            .{ critical, high },
        );
    }

    /// ------------------------------------------------
    /// TREND DETECTION
    /// ------------------------------------------------
    pub fn detectTrends(self: *ThreatDataLake) void {

        std.log.warn(
            "[ThreatDataLake] Trend detection",
            .{},
        );

        var exploit_events: usize = 0;

        for (self.records.items) |record| {

            if (std.mem.indexOf(u8, record.indicator, "exploit")) |_| {

                exploit_events += 1;
            }
        }

        if (exploit_events > 3) {

            std.log.warn(
                "Exploit trend detected events={}",
                .{exploit_events},
            );
        }
    }

    /// ------------------------------------------------
    /// REPORT SUMMARY
    /// ------------------------------------------------
    pub fn report(self: *ThreatDataLake) void {

        std.log.warn(
            "[ThreatDataLake] Data lake summary records={}",
            .{self.records.items.len},
        );

        for (self.records.items) |record| {

            std.log.info(
                "source={s} target={s} indicator={s} severity={}",
                .{
                    record.source,
                    record.target,
                    record.indicator,
                    record.severity,
                },
            );
        }
    }
};