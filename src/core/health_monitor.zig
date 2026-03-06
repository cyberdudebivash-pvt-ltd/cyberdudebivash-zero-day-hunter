const std = @import("std");

pub const SystemHealth = struct {
    active_threads: usize,
    active_tasks: usize,
    allocated_memory: usize,
    cpu_usage_percent: f32,
    uptime_seconds: u64,
};

pub const HealthMonitor = struct {

    allocator: std.mem.Allocator,

    start_time: i64,

    last_health: SystemHealth,

    pub fn init(
        allocator: std.mem.Allocator,
    ) HealthMonitor {

        return HealthMonitor{
            .allocator = allocator,
            .start_time = std.time.timestamp(),
            .last_health = SystemHealth{
                .active_threads = 0,
                .active_tasks = 0,
                .allocated_memory = 0,
                .cpu_usage_percent = 0,
                .uptime_seconds = 0,
            },
        };
    }

    pub fn deinit(self: *HealthMonitor) void {
        _ = self;
    }

    /// Update health metrics from runtime subsystems
    pub fn updateMetrics(
        self: *HealthMonitor,
        threads: usize,
        tasks: usize,
        memory: usize,
        cpu: f32,
    ) void {

        const uptime =
            @as(u64, @intCast(std.time.timestamp() - self.start_time));

        self.last_health = SystemHealth{
            .active_threads = threads,
            .active_tasks = tasks,
            .allocated_memory = memory,
            .cpu_usage_percent = cpu,
            .uptime_seconds = uptime,
        };
    }

    /// Print current system health
    pub fn report(self: *HealthMonitor) void {

        const h = self.last_health;

        std.log.info(
            "📊 Platform Health Report",
            .{},
        );

        std.log.info(
            "Threads: {}",
            .{h.active_threads},
        );

        std.log.info(
            "Tasks: {}",
            .{h.active_tasks},
        );

        std.log.info(
            "Memory Usage: {} bytes",
            .{h.allocated_memory},
        );

        std.log.info(
            "CPU Usage: {d:.2}%",
            .{h.cpu_usage_percent},
        );

        std.log.info(
            "Uptime: {} seconds",
            .{h.uptime_seconds},
        );
    }

    /// Detect abnormal runtime conditions
    pub fn detectAnomalies(self: *HealthMonitor) void {

        const h = self.last_health;

        if (h.cpu_usage_percent > 90) {

            std.log.warn(
                "⚠️ High CPU usage detected: {d:.2}%",
                .{h.cpu_usage_percent},
            );
        }

        if (h.allocated_memory > (1024 * 1024 * 1024)) {

            std.log.warn(
                "⚠️ High memory usage detected: {} bytes",
                .{h.allocated_memory},
            );
        }

        if (h.active_threads > 64) {

            std.log.warn(
                "⚠️ Thread count unusually high: {}",
                .{h.active_threads},
            );
        }

        if (h.active_tasks > 5000) {

            std.log.warn(
                "⚠️ Task load extremely high: {}",
                .{h.active_tasks},
            );
        }
    }

    /// Continuous monitoring loop
    pub fn monitorLoop(
        self: *HealthMonitor,
        interval_seconds: u64,
    ) !void {

        std.log.info(
            "🩺 Health monitor started",
            .{},
        );

        while (true) {

            self.report();
            self.detectAnomalies();

            std.time.sleep(interval_seconds * std.time.ns_per_s);
        }
    }
};