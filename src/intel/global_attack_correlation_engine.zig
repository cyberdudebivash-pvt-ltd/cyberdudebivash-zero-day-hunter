const std = @import("std");

pub const AttackType = enum {
    scan,
    exploit,
    ddos,
    malware_delivery,
    credential_attack,
    unknown,
};

pub const AttackSignal = struct {
    region: []const u8,
    attack_type: AttackType,
    volume: u32,
    anomaly_score: f32,
    timestamp: i64,
};

pub const CorrelatedAttackCluster = struct {
    attack_type: AttackType,
    regions: []const []const u8,
    total_volume: u32,
    average_anomaly: f32,
    start_time: i64,
    end_time: i64,
};

pub const GlobalAttackCorrelationEngine = struct {
    allocator: std.mem.Allocator,

    signals: std.ArrayList(AttackSignal),
    clusters: std.ArrayList(CorrelatedAttackCluster),

    correlation_window: i64,

    pub fn init(
        allocator: std.mem.Allocator,
        correlation_window: i64,
    ) GlobalAttackCorrelationEngine {
        return GlobalAttackCorrelationEngine{
            .allocator = allocator,
            .signals = std.ArrayList(AttackSignal).init(allocator),
            .clusters = std.ArrayList(CorrelatedAttackCluster).init(allocator),
            .correlation_window = correlation_window,
        };
    }

    pub fn deinit(self: *GlobalAttackCorrelationEngine) void {

        for (self.clusters.items) |c| {
            self.allocator.free(c.regions);
        }

        self.signals.deinit();
        self.clusters.deinit();
    }

    pub fn ingestSignal(
        self: *GlobalAttackCorrelationEngine,
        signal: AttackSignal,
    ) !void {
        try self.signals.append(signal);
    }

    fn regionExists(regions: []const []const u8, region: []const u8) bool {
        for (regions) |r| {
            if (std.mem.eql(u8, r, region)) return true;
        }
        return false;
    }

    pub fn correlate(self: *GlobalAttackCorrelationEngine) !void {

        self.clusters.clearRetainingCapacity();

        if (self.signals.items.len == 0)
            return;

        var used = try self.allocator.alloc(bool, self.signals.items.len);
        defer self.allocator.free(used);

        for (used) |*u| u.* = false;

        for (self.signals.items, 0..) |base, i| {

            if (used[i]) continue;

            var region_list = std.ArrayList([]const u8).init(self.allocator);
            defer region_list.deinit();

            try region_list.append(base.region);

            var total_volume: u32 = base.volume;
            var anomaly_sum: f32 = base.anomaly_score;
            var count: u32 = 1;

            var start_time = base.timestamp;
            var end_time = base.timestamp;

            used[i] = true;

            for (self.signals.items, 0..) |other, j| {

                if (i == j or used[j]) continue;

                if (other.attack_type != base.attack_type)
                    continue;

                const delta = std.math.absInt(other.timestamp - base.timestamp) catch 0;

                if (delta > self.correlation_window)
                    continue;

                used[j] = true;

                total_volume += other.volume;
                anomaly_sum += other.anomaly_score;
                count += 1;

                if (other.timestamp < start_time)
                    start_time = other.timestamp;

                if (other.timestamp > end_time)
                    end_time = other.timestamp;

                if (!regionExists(region_list.items, other.region)) {
                    try region_list.append(other.region);
                }
            }

            const avg_anomaly = anomaly_sum / @as(f32, @floatFromInt(count));

            const regions = try self.allocator.alloc([]const u8, region_list.items.len);
            std.mem.copy([]const u8, regions, region_list.items);

            try self.clusters.append(.{
                .attack_type = base.attack_type,
                .regions = regions,
                .total_volume = total_volume,
                .average_anomaly = avg_anomaly,
                .start_time = start_time,
                .end_time = end_time,
            });
        }
    }

    pub fn getClusters(self: *GlobalAttackCorrelationEngine) []CorrelatedAttackCluster {
        return self.clusters.items;
    }

    pub fn clearSignals(self: *GlobalAttackCorrelationEngine) void {
        self.signals.clearRetainingCapacity();
    }

    pub fn clusterCount(self: *GlobalAttackCorrelationEngine) usize {
        return self.clusters.items.len;
    }
};