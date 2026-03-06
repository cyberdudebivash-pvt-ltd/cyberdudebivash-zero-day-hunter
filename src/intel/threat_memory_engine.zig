const std = @import("std");

pub const ThreatRecordType = enum {
    attack_cluster,
    campaign,
    actor,
    technique,
};

pub const ThreatRecord = struct {
    id: u64,
    record_type: ThreatRecordType,
    label: []const u8,
    region: ?[]const u8,
    anomaly_score: f32,
    timestamp: i64,
};

pub const MemoryQueryResult = struct {
    id: u64,
    label: []const u8,
    record_type: ThreatRecordType,
    anomaly_score: f32,
    timestamp: i64,
};

pub const ThreatMemoryEngine = struct {
    allocator: std.mem.Allocator,

    records: std.ArrayList(ThreatRecord),

    label_index: std.StringHashMap(std.ArrayList(u64)),

    next_id: u64,

    pub fn init(allocator: std.mem.Allocator) ThreatMemoryEngine {
        return ThreatMemoryEngine{
            .allocator = allocator,
            .records = std.ArrayList(ThreatRecord).init(allocator),
            .label_index = std.StringHashMap(std.ArrayList(u64)).init(allocator),
            .next_id = 1,
        };
    }

    pub fn deinit(self: *ThreatMemoryEngine) void {

        var it = self.label_index.iterator();

        while (it.next()) |entry| {
            entry.value_ptr.*.deinit();
        }

        self.label_index.deinit();
        self.records.deinit();
    }

    pub fn storeRecord(
        self: *ThreatMemoryEngine,
        record_type: ThreatRecordType,
        label: []const u8,
        region: ?[]const u8,
        anomaly_score: f32,
        timestamp: i64,
    ) !u64 {

        const id = self.next_id;
        self.next_id += 1;

        try self.records.append(.{
            .id = id,
            .record_type = record_type,
            .label = label,
            .region = region,
            .anomaly_score = anomaly_score,
            .timestamp = timestamp,
        });

        const entry = try self.label_index.getOrPut(label);

        if (!entry.found_existing) {
            entry.value_ptr.* = std.ArrayList(u64).init(self.allocator);
        }

        try entry.value_ptr.append(id);

        return id;
    }

    pub fn queryByLabel(
        self: *ThreatMemoryEngine,
        label: []const u8,
    ) ![]MemoryQueryResult {

        const ids = self.label_index.get(label) orelse return &[_]MemoryQueryResult{};

        var results = std.ArrayList(MemoryQueryResult).init(self.allocator);

        for (ids.items) |id| {

            const index = id - 1;

            if (index >= self.records.items.len)
                continue;

            const rec = self.records.items[index];

            try results.append(.{
                .id = rec.id,
                .label = rec.label,
                .record_type = rec.record_type,
                .anomaly_score = rec.anomaly_score,
                .timestamp = rec.timestamp,
            });
        }

        return results.toOwnedSlice();
    }

    pub fn queryByRegion(
        self: *ThreatMemoryEngine,
        region: []const u8,
    ) ![]MemoryQueryResult {

        var results = std.ArrayList(MemoryQueryResult).init(self.allocator);

        for (self.records.items) |rec| {

            if (rec.region) |r| {

                if (!std.mem.eql(u8, r, region))
                    continue;

                try results.append(.{
                    .id = rec.id,
                    .label = rec.label,
                    .record_type = rec.record_type,
                    .anomaly_score = rec.anomaly_score,
                    .timestamp = rec.timestamp,
                });
            }
        }

        return results.toOwnedSlice();
    }

    pub fn queryByType(
        self: *ThreatMemoryEngine,
        record_type: ThreatRecordType,
    ) ![]MemoryQueryResult {

        var results = std.ArrayList(MemoryQueryResult).init(self.allocator);

        for (self.records.items) |rec| {

            if (rec.record_type != record_type)
                continue;

            try results.append(.{
                .id = rec.id,
                .label = rec.label,
                .record_type = rec.record_type,
                .anomaly_score = rec.anomaly_score,
                .timestamp = rec.timestamp,
            });
        }

        return results.toOwnedSlice();
    }

    pub fn recordCount(self: *ThreatMemoryEngine) usize {
        return self.records.items.len;
    }

    pub fn clear(self: *ThreatMemoryEngine) void {

        var it = self.label_index.iterator();

        while (it.next()) |entry| {
            entry.value_ptr.*.clearRetainingCapacity();
        }

        self.records.clearRetainingCapacity();
        self.next_id = 1;
    }
};