const std = @import("std");

pub const AttackType = enum {
    scan,
    exploit,
    ddos,
    malware_delivery,
    credential_attack,
};

pub const SensorRegion = enum {
    us_east,
    us_west,
    eu_west,
    eu_central,
    apac_sg,
    apac_jp,
    latam,
    mea,
};

pub const SensorEvent = struct {
    region: SensorRegion,
    attack_type: AttackType,
    volume: u32,
    anomaly_score: f32,
    timestamp: i64,
};

pub const SensorNode = struct {
    id: u64,
    region: SensorRegion,
    enabled: bool,
};

pub const DistributedSensorGrid = struct {
    allocator: std.mem.Allocator,

    sensors: std.ArrayList(SensorNode),
    events: std.ArrayList(SensorEvent),

    next_sensor_id: u64,
    rng: std.rand.DefaultPrng,

    pub fn init(allocator: std.mem.Allocator) DistributedSensorGrid {
        var seed: u64 = @intCast(std.time.timestamp());
        return DistributedSensorGrid{
            .allocator = allocator,
            .sensors = std.ArrayList(SensorNode).init(allocator),
            .events = std.ArrayList(SensorEvent).init(allocator),
            .next_sensor_id = 1,
            .rng = std.rand.DefaultPrng.init(seed),
        };
    }

    pub fn deinit(self: *DistributedSensorGrid) void {
        self.sensors.deinit();
        self.events.deinit();
    }

    pub fn registerSensor(
        self: *DistributedSensorGrid,
        region: SensorRegion,
    ) !u64 {

        const id = self.next_sensor_id;
        self.next_sensor_id += 1;

        try self.sensors.append(.{
            .id = id,
            .region = region,
            .enabled = true,
        });

        return id;
    }

    pub fn disableSensor(self: *DistributedSensorGrid, id: u64) void {

        for (self.sensors.items) |*sensor| {
            if (sensor.id == id) {
                sensor.enabled = false;
                return;
            }
        }
    }

    fn randomAttackType(rng: *std.rand.Random) AttackType {
        const v = rng.uintLessThan(u8, 5);
        return switch (v) {
            0 => .scan,
            1 => .exploit,
            2 => .ddos,
            3 => .malware_delivery,
            else => .credential_attack,
        };
    }

    fn randomVolume(rng: *std.rand.Random) u32 {
        return rng.uintLessThan(u32, 500) + 50;
    }

    fn randomAnomaly(rng: *std.rand.Random) f32 {
        const value = rng.uintLessThan(u32, 100);
        return @as(f32, @floatFromInt(value)) / 100.0;
    }

    pub fn generateTelemetry(self: *DistributedSensorGrid) !void {

        const now = std.time.timestamp();
        var random = self.rng.random();

        for (self.sensors.items) |sensor| {

            if (!sensor.enabled)
                continue;

            const event = SensorEvent{
                .region = sensor.region,
                .attack_type = randomAttackType(&random),
                .volume = randomVolume(&random),
                .anomaly_score = randomAnomaly(&random),
                .timestamp = now,
            };

            try self.events.append(event);
        }
    }

    pub fn ingestExternalEvent(
        self: *DistributedSensorGrid,
        event: SensorEvent,
    ) !void {
        try self.events.append(event);
    }

    pub fn getEvents(self: *DistributedSensorGrid) []SensorEvent {
        return self.events.items;
    }

    pub fn clearEvents(self: *DistributedSensorGrid) void {
        self.events.clearRetainingCapacity();
    }

    pub fn sensorCount(self: *DistributedSensorGrid) usize {
        return self.sensors.items.len;
    }

    pub fn eventCount(self: *DistributedSensorGrid) usize {
        return self.events.items.len;
    }
};