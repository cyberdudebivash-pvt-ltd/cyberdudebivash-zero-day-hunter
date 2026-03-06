const std = @import("std");

const HunterRegistry = @import("../hunters/registry.zig").HunterRegistry;
const HunterRuntime = @import("../hunters/runtime.zig").HunterRuntime;

const MemoryHunter = @import("../hunters/memory.zig").MemoryHunter;

/// Optional future scanners
const GlobalScanner = @import("../intel/global_scanner.zig");

pub const Engine = struct {

    allocator: std.mem.Allocator,

    hunters: HunterRegistry,
    runtime: HunterRuntime,

    /// engine configuration
    worker_count: usize,

    /// ----------------------------------------------------
    /// INIT
    /// ----------------------------------------------------

    pub fn init(
        allocator: std.mem.Allocator,
        worker_count: usize,
    ) !Engine {

        std.log.info("[Engine] Initializing CYBERDUDEBIVASH detection engine", .{});

        var registry = HunterRegistry.init(allocator);

        var runtime = HunterRuntime.init(
            allocator,
            worker_count,
        );

        return .{
            .allocator = allocator,
            .hunters = registry,
            .runtime = runtime,
            .worker_count = worker_count,
        };
    }

    /// ----------------------------------------------------
    /// SHUTDOWN
    /// ----------------------------------------------------

    pub fn deinit(self: *Engine) void {

        std.log.info("[Engine] Shutting down engine", .{});

        self.hunters.deinit();
        self.runtime.deinit();
    }

    /// ----------------------------------------------------
    /// LOAD HUNTERS
    /// ----------------------------------------------------

    pub fn loadHunters(self: *Engine) !void {

        std.log.info("[Engine] Loading hunters...", .{});

        try self.hunters.register(MemoryHunter);

        std.log.info(
            "[Engine] Hunters loaded: {}",
            .{self.hunters.count()},
        );
    }

    /// ----------------------------------------------------
    /// SOC OUTPUT PIPELINE
    /// ----------------------------------------------------

    fn socEvent(
        target: []const u8,
    ) void {

        std.log.info(
            "[SOC] Detection cycle completed for target: {s}",
            .{target},
        );
    }

    /// ----------------------------------------------------
    /// RUN HUNTERS
    /// ----------------------------------------------------

    fn runDetection(
        self: *Engine,
        target: []const u8,
    ) !void {

        std.log.info(
            "[Engine] Running detection pipeline for {s}",
            .{target},
        );

        try self.runtime.runHunters(
            self.hunters.hunters.items,
            target,
        );

        socEvent(target);
    }

    /// ----------------------------------------------------
    /// GLOBAL SCAN
    /// ----------------------------------------------------

    fn scanTargets(
        self: *Engine,
        targets: [][]const u8,
    ) !void {

        for (targets) |target| {

            std.log.info(
                "[Engine] Starting scan for target: {s}",
                .{target},
            );

            try self.runDetection(target);
        }
    }

    /// ----------------------------------------------------
    /// ENGINE START
    /// ----------------------------------------------------

    pub fn start(
        self: *Engine,
        targets: [][]const u8,
    ) !void {

        std.log.info(
            "[Engine] Starting CYBERDUDEBIVASH ZERO-DAY HUNTER™",
            .{},
        );

        try self.loadHunters();

        self.hunters.list();

        try self.scanTargets(targets);

        std.log.info(
            "[Engine] Detection cycle finished",
            .{},
        );
    }
};