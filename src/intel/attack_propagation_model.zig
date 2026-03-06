const std = @import("std");

pub const AttackType = enum {
    scan,
    exploit,
    ddos,
    malware_delivery,
    credential_attack,
    unknown,
};

pub const AttackCluster = struct {
    attack_type: AttackType,
    regions: []const []const u8,
    total_volume: u32,
    anomaly_score: f32,
    start_time: i64,
    end_time: i64,
};

pub const PropagationPrediction = struct {
    attack_type: AttackType,
    source_regions: []const []const u8,
    predicted_regions: []const []const u8,
    propagation_score: f32,
    confidence: f32,
};

pub const AttackPropagationModel = struct {
    allocator: std.mem.Allocator,

    clusters: std.ArrayList(AttackCluster),
    predictions: std.ArrayList(PropagationPrediction),

    known_regions: []const []const u8,

    pub fn init(
        allocator: std.mem.Allocator,
        known_regions: []const []const u8,
    ) AttackPropagationModel {
        return AttackPropagationModel{
            .allocator = allocator,
            .clusters = std.ArrayList(AttackCluster).init(allocator),
            .predictions = std.ArrayList(PropagationPrediction).init(allocator),
            .known_regions = known_regions,
        };
    }

    pub fn deinit(self: *AttackPropagationModel) void {

        for (self.predictions.items) |p| {
            self.allocator.free(p.predicted_regions);
        }

        self.clusters.deinit();
        self.predictions.deinit();
    }

    pub fn ingestCluster(
        self: *AttackPropagationModel,
        cluster: AttackCluster,
    ) !void {
        try self.clusters.append(cluster);
    }

    fn regionExists(regions: []const []const u8, region: []const u8) bool {
        for (regions) |r| {
            if (std.mem.eql(u8, r, region))
                return true;
        }
        return false;
    }

    fn calculatePropagationScore(volume: u32, anomaly: f32) f32 {

        const volume_factor =
            @as(f32, @floatFromInt(volume)) / 2000.0;

        var score =
            (volume_factor * 0.6) +
            (anomaly * 0.4);

        if (score > 1.0)
            score = 1.0;

        return score;
    }

    pub fn predict(self: *AttackPropagationModel) !void {

        self.predictions.clearRetainingCapacity();

        if (self.clusters.items.len == 0)
            return;

        for (self.clusters.items) |cluster| {

            var predicted = std.ArrayList([]const u8).init(self.allocator);
            defer predicted.deinit();

            for (self.known_regions) |region| {

                if (regionExists(cluster.regions, region))
                    continue;

                try predicted.append(region);
            }

            if (predicted.items.len == 0)
                continue;

            const propagation_score =
                calculatePropagationScore(
                    cluster.total_volume,
                    cluster.anomaly_score,
                );

            const confidence =
                (cluster.anomaly_score * 0.7) +
                (propagation_score * 0.3);

            const predicted_regions =
                try self.allocator.alloc([]const u8, predicted.items.len);

            std.mem.copy(
                []const u8,
                predicted_regions,
                predicted.items,
            );

            try self.predictions.append(.{
                .attack_type = cluster.attack_type,
                .source_regions = cluster.regions,
                .predicted_regions = predicted_regions,
                .propagation_score = propagation_score,
                .confidence = confidence,
            });
        }
    }

    pub fn getPredictions(
        self: *AttackPropagationModel,
    ) []PropagationPrediction {
        return self.predictions.items;
    }

    pub fn clearClusters(self: *AttackPropagationModel) void {
        self.clusters.clearRetainingCapacity();
    }

    pub fn predictionCount(self: *AttackPropagationModel) usize {
        return self.predictions.items.len;
    }
};