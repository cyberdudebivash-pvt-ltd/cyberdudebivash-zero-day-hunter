const std = @import("std");

pub const AttackStage = enum {
    reconnaissance,
    exploitation,
    credential_access,
    lateral_movement,
    command_control,
};

pub const AttackType = enum {
    scan,
    exploit,
    credential_attack,
    malware_delivery,
    ddos,
};

pub const Region = enum {
    us_east,
    us_west,
    eu_west,
    eu_central,
    apac_sg,
    apac_jp,
    latam,
    mea,
};

pub const AdversaryProfile = struct {
    name: []const u8,
    sophistication: f32,
    aggression: f32,
};

pub const SimulatedAttack = struct {
    stage: AttackStage,
    attack_type: AttackType,
    region: Region,
    volume: u32,
    anomaly_score: f32,
    timestamp: i64,
};

pub const AdversarySimulator = struct {
    allocator: std.mem.Allocator,

    profiles: std.ArrayList(AdversaryProfile),
    attacks: std.ArrayList(SimulatedAttack),

    rng: std.rand.DefaultPrng,

    pub fn init(allocator: std.mem.Allocator) AdversarySimulator {

        var seed: u64 = @intCast(std.time.timestamp());

        return AdversarySimulator{
            .allocator = allocator,
            .profiles = std.ArrayList(AdversaryProfile).init(allocator),
            .attacks = std.ArrayList(SimulatedAttack).init(allocator),
            .rng = std.rand.DefaultPrng.init(seed),
        };
    }

    pub fn deinit(self: *AdversarySimulator) void {
        self.profiles.deinit();
        self.attacks.deinit();
    }

    pub fn registerProfile(
        self: *AdversarySimulator,
        name: []const u8,
        sophistication: f32,
        aggression: f32,
    ) !void {

        try self.profiles.append(.{
            .name = name,
            .sophistication = sophistication,
            .aggression = aggression,
        });
    }

    fn randomStage(rng: *std.rand.Random) AttackStage {
        const v = rng.uintLessThan(u8, 5);
        return switch (v) {
            0 => .reconnaissance,
            1 => .exploitation,
            2 => .credential_access,
            3 => .lateral_movement,
            else => .command_control,
        };
    }

    fn stageToAttackType(stage: AttackStage) AttackType {
        return switch (stage) {
            .reconnaissance => .scan,
            .exploitation => .exploit,
            .credential_access => .credential_attack,
            .lateral_movement => .malware_delivery,
            .command_control => .ddos,
        };
    }

    fn randomRegion(rng: *std.rand.Random) Region {
        const v = rng.uintLessThan(u8, 8);
        return switch (v) {
            0 => .us_east,
            1 => .us_west,
            2 => .eu_west,
            3 => .eu_central,
            4 => .apac_sg,
            5 => .apac_jp,
            6 => .latam,
            else => .mea,
        };
    }

    fn computeVolume(rng: *std.rand.Random, aggression: f32) u32 {

        const base = rng.uintLessThan(u32, 200) + 50;

        return @as(u32, @intFromFloat(@as(f32, @floatFromInt(base)) * (1.0 + aggression)));
    }

    fn computeAnomaly(rng: *std.rand.Random, sophistication: f32) f32 {

        const base = rng.uintLessThan(u32, 100);

        const anomaly =
            (@as(f32, @floatFromInt(base)) / 100.0) *
            (0.5 + sophistication);

        if (anomaly > 1.0)
            return 1.0;

        return anomaly;
    }

    pub fn simulate(self: *AdversarySimulator) !void {

        var random = self.rng.random();

        const now = std.time.timestamp();

        for (self.profiles.items) |profile| {

            const stage = randomStage(&random);
            const attack_type = stageToAttackType(stage);
            const region = randomRegion(&random);

            const volume = computeVolume(&random, profile.aggression);

            const anomaly =
                computeAnomaly(&random, profile.sophistication);

            try self.attacks.append(.{
                .stage = stage,
                .attack_type = attack_type,
                .region = region,
                .volume = volume,
                .anomaly_score = anomaly,
                .timestamp = now,
            });
        }
    }

    pub fn getAttacks(self: *AdversarySimulator) []SimulatedAttack {
        return self.attacks.items;
    }

    pub fn clearAttacks(self: *AdversarySimulator) void {
        self.attacks.clearRetainingCapacity();
    }

    pub fn profileCount(self: *AdversarySimulator) usize {
        return self.profiles.items.len;
    }

    pub fn attackCount(self: *AdversarySimulator) usize {
        return self.attacks.items.len;
    }
};