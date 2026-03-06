const std = @import("std");

pub const ResourceLimits = struct {
    max_threads: usize,
    max_tasks: usize,
    max_memory_bytes: usize,
};

pub const ResourceManager = struct {

    allocator: std.mem.Allocator,

    limits: ResourceLimits,

    active_threads: usize,
    active_tasks: usize,
    allocated_memory: usize,

    pub fn init(
        allocator: std.mem.Allocator,
        limits: ResourceLimits,
    ) ResourceManager {

        return ResourceManager{
            .allocator = allocator,
            .limits = limits,
            .active_threads = 0,
            .active_tasks = 0,
            .allocated_memory = 0,
        };
    }

    pub fn deinit(self: *ResourceManager) void {
        _ = self;
    }

    /// Request permission to spawn a worker thread
    pub fn requestThread(self: *ResourceManager) !void {

        if (self.active_threads >= self.limits.max_threads) {

            std.log.warn(
                "⚠️ Thread limit reached ({})",
                .{self.limits.max_threads},
            );

            return error.ThreadLimitExceeded;
        }

        self.active_threads += 1;

        std.log.info(
            "🧵 Thread allocated. Active threads: {}",
            .{self.active_threads},
        );
    }

    /// Release worker thread
    pub fn releaseThread(self: *ResourceManager) void {

        if (self.active_threads > 0)
            self.active_threads -= 1;

        std.log.info(
            "🧵 Thread released. Active threads: {}",
            .{self.active_threads},
        );
    }

    /// Request task slot
    pub fn requestTask(self: *ResourceManager) !void {

        if (self.active_tasks >= self.limits.max_tasks) {

            std.log.warn(
                "⚠️ Task limit reached ({})",
                .{self.limits.max_tasks},
            );

            return error.TaskLimitExceeded;
        }

        self.active_tasks += 1;

        std.log.info(
            "📦 Task allocated. Active tasks: {}",
            .{self.active_tasks},
        );
    }

    /// Release task slot
    pub fn releaseTask(self: *ResourceManager) void {

        if (self.active_tasks > 0)
            self.active_tasks -= 1;

        std.log.info(
            "📦 Task released. Active tasks: {}",
            .{self.active_tasks},
        );
    }

    /// Track memory allocations
    pub fn allocateMemory(
        self: *ResourceManager,
        bytes: usize,
    ) !void {

        if (self.allocated_memory + bytes > self.limits.max_memory_bytes) {

            std.log.warn(
                "⚠️ Memory limit exceeded ({} bytes)",
                .{self.limits.max_memory_bytes},
            );

            return error.MemoryLimitExceeded;
        }

        self.allocated_memory += bytes;

        std.log.info(
            "💾 Memory allocated: {} bytes (total: {})",
            .{bytes, self.allocated_memory},
        );
    }

    /// Release tracked memory
    pub fn freeMemory(
        self: *ResourceManager,
        bytes: usize,
    ) void {

        if (self.allocated_memory >= bytes)
            self.allocated_memory -= bytes;

        std.log.info(
            "💾 Memory released: {} bytes (total: {})",
            .{bytes, self.allocated_memory},
        );
    }

    /// Show runtime resource usage
    pub fn status(self: *ResourceManager) void {

        std.log.info(
            "📊 Resource Status",
            .{},
        );

        std.log.info(
            "Threads: {}/{}",
            .{self.active_threads, self.limits.max_threads},
        );

        std.log.info(
            "Tasks: {}/{}",
            .{self.active_tasks, self.limits.max_tasks},
        );

        std.log.info(
            "Memory: {}/{} bytes",
            .{self.allocated_memory, self.limits.max_memory_bytes},
        );
    }
};