const std = @import("std");

pub const Technique = struct {
    id: []const u8,
    name: []const u8,
};

pub const TTPObservation = struct {
    technique_id: []const u8,
    weight: f32,
};

pub const CampaignTTPProfile = struct {
    name: []const u8,
    techniques: []const []const u8,
};

pub const CorrelationResult = struct {
    profile_name: []const u8,
    score: f32,
};

pub const TTPCorrelationEngine = struct {
    allocator: std.mem.Allocator,

    observations: std.ArrayList(TTPObservation),
    profiles: std.ArrayList(CampaignTTPProfile),
    results: std.ArrayList(CorrelationResult),

    pub fn init(allocator: std.mem.Allocator) !TTPCorrelationEngine {
        var engine = TTPCorrelationEngine{
            .allocator = allocator,
            .observations = std.ArrayList(TTPObservation).init(allocator),
            .profiles = std.ArrayList(CampaignTTPProfile).init(allocator),
            .results = std.ArrayList(CorrelationResult).init(allocator),
        };

        try engine.loadDefaultProfiles();
        return engine;
    }

    pub fn deinit(self: *TTPCorrelationEngine) void {
        self.observations.deinit();

        for (self.profiles.items) |p| {
            self.allocator.free(p.techniques);
        }

        self.profiles.deinit();
        self.results.deinit();
    }

    fn loadDefaultProfiles(self: *TTPCorrelationEngine) !void {

        const apt29 = try self.allocator.alloc([]const u8, 3);
        apt29[0] = "T1190";
        apt29[1] = "T1059";
        apt29[2] = "T1046";

        try self.profiles.append(.{
            .name = "APT29 Behavior Cluster",
            .techniques = apt29,
        });

        const ransomware = try self.allocator.alloc([]const u8, 3);
        ransomware[0] = "T1486";
        ransomware[1] = "T1566";
        ransomware[2] = "T1021";

        try self.profiles.append(.{
            .name = "Ransomware Campaign Pattern",
            .techniques = ransomware,
        });

        const botnet = try self.allocator.alloc([]const u8, 3);
        botnet[0] = "T1071";
        botnet[1] = "T1046";
        botnet[2] = "T1090";

        try self.profiles.append(.{
            .name = "Botnet Operation Pattern",
            .techniques = botnet,
        });
    }

    pub fn ingestObservation(
        self: *TTPCorrelationEngine,
        technique_id: []const u8,
        weight: f32,
    ) !void {
        try self.observations.append(.{
            .technique_id = technique_id,
            .weight = weight,
        });
    }

    fn techniqueObserved(self: *TTPCorrelationEngine, id: []const u8) bool {
        for (self.observations.items) |obs| {
            if (std.mem.eql(u8, obs.technique_id, id)) {
                return true;
            }
        }
        return false;
    }

    pub fn correlate(self: *TTPCorrelationEngine) !void {

        self.results.clearRetainingCapacity();

        for (self.profiles.items) |profile| {

            var matches: u32 = 0;

            for (profile.techniques) |tech| {
                if (self.techniqueObserved(tech)) {
                    matches += 1;
                }
            }

            if (matches == 0)
                continue;

            const score =
                @as(f32, @floatFromInt(matches)) /
                @as(f32, @floatFromInt(profile.techniques.len));

            try self.results.append(.{
                .profile_name = profile.name,
                .score = score,
            });
        }

        std.sort.sort(
            CorrelationResult,
            self.results.items,
            {},
            struct {
                fn lessThan(_: void, a: CorrelationResult, b: CorrelationResult) bool {
                    return a.score > b.score;
                }
            }.lessThan,
        );
    }

    pub fn getResults(self: *TTPCorrelationEngine) []CorrelationResult {
        return self.results.items;
    }

    pub fn clearObservations(self: *TTPCorrelationEngine) void {
        self.observations.clearRetainingCapacity();
    }
};