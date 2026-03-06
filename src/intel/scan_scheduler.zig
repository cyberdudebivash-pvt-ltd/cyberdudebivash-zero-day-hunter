const std = @import("std");

pub const ScanTask = struct {
    id: u64,
    target: []const u8,
    priority: u8,
};

var next_task_id: u64 = 1;

pub fn createTask(target: []const u8, priority: u8) ScanTask {
    const task = ScanTask{
        .id = next_task_id,
        .target = target,
        .priority = priority,
    };

    next_task_id += 1;

    std.debug.print(
        "📌 New scan task created | ID: {d} | Target: {s}\n",
        .{ task.id, task.target },
    );

    return task;
}

pub fn assignTask(node_id: []const u8, task: ScanTask) void {
    std.debug.print(
        "📡 Assigning task {d} to node {s} → {s}\n",
        .{ task.id, node_id, task.target },
    );
}

pub fn completeTask(task: ScanTask) void {
    std.debug.print(
        "✅ Task completed | ID: {d} | Target: {s}\n",
        .{ task.id, task.target },
    );
}

pub fn scheduleExample() void {
    const task = createTask("example.com", 1);

    assignTask("node-alpha", task);

    completeTask(task);
}