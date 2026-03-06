const std = @import("std");

pub const TaskState = enum {
    pending,
    running,
    completed,
    failed,
};

pub const ScheduledTask = struct {
    id: u64,
    name: []const u8,
    priority: u8,

    handler: *const fn (*ScheduledTask) anyerror!void,

    state: TaskState = .pending,

    created_at: i64,
    started_at: i64 = 0,
    finished_at: i64 = 0,
};

pub const RuntimeScheduler = struct {

    allocator: std.mem.Allocator,
    tasks: std.ArrayList(ScheduledTask),

    next_id: u64,

    running: bool,
    worker_thread: ?std.Thread,

    pub fn init(allocator: std.mem.Allocator) RuntimeScheduler {
        return RuntimeScheduler{
            .allocator = allocator,
            .tasks = std.ArrayList(ScheduledTask).init(allocator),
            .next_id = 1,
            .running = false,
            .worker_thread = null,
        };
    }

    pub fn deinit(self: *RuntimeScheduler) void {
        self.tasks.deinit();
    }

    // ------------------------------------------------------------
    // TASK REGISTRATION
    // ------------------------------------------------------------

    pub fn registerTask(
        self: *RuntimeScheduler,
        name: []const u8,
        priority: u8,
        handler: *const fn (*ScheduledTask) anyerror!void,
    ) !u64 {

        const task = ScheduledTask{
            .id = self.next_id,
            .name = name,
            .priority = priority,
            .handler = handler,
            .created_at = std.time.timestamp(),
        };

        try self.tasks.append(task);

        std.debug.print(
            "[Scheduler] Task registered: {s} id={d} priority={d}\n",
            .{ name, task.id, priority },
        );

        self.next_id += 1;

        return task.id;
    }

    // ------------------------------------------------------------
    // START SCHEDULER
    // ------------------------------------------------------------

    pub fn start(self: *RuntimeScheduler) !void {

        if (self.running) return;

        self.running = true;

        self.worker_thread = try std.Thread.spawn(
            .{},
            workerLoop,
            .{self},
        );

        std.debug.print("[Scheduler] Started\n", .{});
    }

    // ------------------------------------------------------------
    // STOP SCHEDULER
    // ------------------------------------------------------------

    pub fn stop(self: *RuntimeScheduler) void {

        self.running = false;

        if (self.worker_thread) |thread| {
            thread.join();
        }

        std.debug.print("[Scheduler] Stopped\n", .{});
    }

    // ------------------------------------------------------------
    // WORKER LOOP
    // ------------------------------------------------------------

    fn workerLoop(self: *RuntimeScheduler) void {

        while (self.running) {

            self.executePendingTasks();

            std.time.sleep(100 * std.time.ns_per_ms);
        }
    }

    // ------------------------------------------------------------
    // EXECUTE TASKS
    // ------------------------------------------------------------

    fn executePendingTasks(self: *RuntimeScheduler) void {

        const sorted = self.tasks.items;

        std.mem.sort(
            ScheduledTask,
            sorted,
            {},
            comparePriority,
        );

        for (sorted) |*task| {

            if (task.state == .pending) {

                const ok = self.executeTask(task);

                if (!ok) {
                    std.debug.print(
                        "[Scheduler] Task failed: {s}\n",
                        .{task.name},
                    );
                }
            }
        }
    }

    fn comparePriority(_: void, a: ScheduledTask, b: ScheduledTask) bool {
        return a.priority > b.priority;
    }

    // ------------------------------------------------------------
    // EXECUTE SINGLE TASK
    // ------------------------------------------------------------

    fn executeTask(_: *RuntimeScheduler, task: *ScheduledTask) bool {

        task.state = .running;
        task.started_at = std.time.timestamp();

        const result = task.handler(task);

        if (result) |_| {

            task.state = .completed;
            task.finished_at = std.time.timestamp();

            std.debug.print(
                "[Scheduler] Task completed: {s}\n",
                .{task.name},
            );

            return true;

        } else |err| {

            task.state = .failed;
            task.finished_at = std.time.timestamp();

            std.debug.print(
                "[Scheduler] Task error: {s} -> {any}\n",
                .{ task.name, err },
            );

            return false;
        }
    }

    // ------------------------------------------------------------
    // DEBUG TASK LIST
    // ------------------------------------------------------------

    pub fn listTasks(self: *RuntimeScheduler) void {

        for (self.tasks.items) |task| {

            std.debug.print(
                "Task {d} [{s}] priority={d} state={any}\n",
                .{ task.id, task.name, task.priority, task.state },
            );
        }
    }

    // ------------------------------------------------------------
    // RUNTIME METRICS
    // ------------------------------------------------------------

    pub fn stats(self: *RuntimeScheduler) void {

        var pending: usize = 0;
        var running: usize = 0;
        var completed: usize = 0;
        var failed: usize = 0;

        for (self.tasks.items) |task| {

            switch (task.state) {
                .pending => pending += 1,
                .running => running += 1,
                .completed => completed += 1,
                .failed => failed += 1,
            }
        }

        std.debug.print(
            "[Scheduler Stats] pending={d} running={d} completed={d} failed={d}\n",
            .{ pending, running, completed, failed },
        );
    }
};