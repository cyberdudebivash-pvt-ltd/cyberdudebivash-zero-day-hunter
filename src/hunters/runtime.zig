const std = @import("std");

const HunterInterface = @import("interface.zig").HunterInterface;
const HunterResult = @import("interface.zig").HunterResult;

/// Worker task passed to each thread
const Task = struct {
    hunter: *const HunterInterface,
    allocator: std.mem.Allocator,
    target: []const u8,
};

/// Runtime responsible for executing hunters in parallel
pub const HunterRuntime = struct {
    allocator: std.mem.Allocator,
    worker_count: usize,

    pub fn init(allocator: std.mem.Allocator, worker_count: usize) HunterRuntime {
        return .{
            .allocator = allocator,
            .worker_count = if (worker_count == 0) 1 else worker_count,
        };
    }

    pub fn deinit(self: *HunterRuntime) void {
        _ = self;
    }

    /// Thread entry function
    fn worker(task: Task) void {

        const hunter = task.hunter;

        std.log.info(
            "[Runtime] Worker executing hunter: {s}",
            .{hunter.name},
        );

        var result = hunter.run(task.allocator, task.target) catch |err| {
            std.log.err(
                "[Runtime] Hunter {s} failed: {}",
                .{ hunter.name, err },
            );
            return;
        };

        defer result.clean(task.allocator);

        if (result.detected) {
            std.log.warn(
                "[THREAT DETECTED] {s} severity={s}",
                .{ result.title, @tagName(result.severity) },
            );
        } else {
            std.log.info(
                "[Runtime] No threat detected by {s}",
                .{hunter.name},
            );
        }
    }

    /// Execute hunters using a worker pool
    pub fn runHunters(
        self: *HunterRuntime,
        hunters: []const HunterInterface,
        target: []const u8,
    ) !void {

        if (hunters.len == 0) {
            std.log.warn("[Runtime] No hunters to execute.", .{});
            return;
        }

        var threads = try self.allocator.alloc(std.Thread, hunters.len);
        defer self.allocator.free(threads);

        for (hunters, 0..) |hunter, i| {

            const task = Task{
                .hunter = &hunter,
                .allocator = self.allocator,
                .target = target,
            };

            threads[i] = try std.Thread.spawn(.{}, worker, .{task});
        }

        /// Wait for all workers
        for (threads) |thread| {
            thread.join();
        }

        std.log.info("[Runtime] Hunter execution complete.", .{});
    }
};