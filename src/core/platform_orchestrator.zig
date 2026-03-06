const std = @import("std");

pub const EngineState = enum {
    idle,
    running,
    completed,
    failed,
};

pub const EngineStatus = struct {
    name: []const u8,
    state: EngineState,
};

pub const PlatformCycleReport = struct {
    cycle_id: u64,
    engine_count: usize,
    completed_engines: usize,
    timestamp: i64,
};

pub const PlatformOrchestrator = struct {
    allocator: std.mem.Allocator,

    engines: std.ArrayList(EngineStatus),

    cycle_counter: u64,

    last_report: ?PlatformCycleReport,

    pub fn init(allocator: std.mem.Allocator) PlatformOrchestrator {
        return PlatformOrchestrator{
            .allocator = allocator,
            .engines = std.ArrayList(EngineStatus).init(allocator),
            .cycle_counter = 0,
            .last_report = null,
        };
    }

    pub fn deinit(self: *PlatformOrchestrator) void {
        self.engines.deinit();
    }

    pub fn registerEngine(
        self: *PlatformOrchestrator,
        name: []const u8,
    ) !void {

        try self.engines.append(.{
            .name = name,
            .state = .idle,
        });
    }

    fn setState(
        self: *PlatformOrchestrator,
        name: []const u8,
        state: EngineState,
    ) void {

        for (self.engines.items) |*engine| {

            if (std.mem.eql(u8, engine.name, name)) {
                engine.state = state;
                return;
            }
        }
    }

    pub fn startCycle(self: *PlatformOrchestrator) void {

        self.cycle_counter += 1;

        for (self.engines.items) |*engine| {
            engine.state = .idle;
        }
    }

    pub fn runEngine(
        self: *PlatformOrchestrator,
        name: []const u8,
        engine_fn: fn () anyerror!void,
    ) void {

        self.setState(name, .running);

        const result = engine_fn();

        if (result) |_| {
            self.setState(name, .completed);
        } else |_| {
            self.setState(name, .failed);
        }
    }

    pub fn finalizeCycle(self: *PlatformOrchestrator) void {

        var completed: usize = 0;

        for (self.engines.items) |engine| {
            if (engine.state == .completed)
                completed += 1;
        }

        self.last_report = PlatformCycleReport{
            .cycle_id = self.cycle_counter,
            .engine_count = self.engines.items.len,
            .completed_engines = completed,
            .timestamp = std.time.timestamp(),
        };
    }

    pub fn getEngineStates(self: *PlatformOrchestrator) []EngineStatus {
        return self.engines.items;
    }

    pub fn getLastReport(self: *PlatformOrchestrator) ?PlatformCycleReport {
        return self.last_report;
    }

    pub fn engineCount(self: *PlatformOrchestrator) usize {
        return self.engines.items.len;
    }

    pub fn clear(self: *PlatformOrchestrator) void {
        self.engines.clearRetainingCapacity();
        self.cycle_counter = 0;
        self.last_report = null;
    }
};