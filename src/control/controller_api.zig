const std = @import("std");

pub const Node = struct {
    id: []const u8,
    ip: []const u8,
};

pub const Task = struct {
    id: u64,
    target: []const u8,
};

var next_task_id: u64 = 1;

pub fn registerNode(ip: []const u8) Node {

    const node_id = "node-auto";

    std.debug.print(
        "🛰 Node registered | ID: {s} | IP: {s}\n",
        .{ node_id, ip },
    );

    return Node{
        .id = node_id,
        .ip = ip,
    };
}

pub fn createTask(target: []const u8) Task {

    const task = Task{
        .id = next_task_id,
        .target = target,
    };

    next_task_id += 1;

    std.debug.print(
        "📌 New task created | ID: {d} | Target: {s}\n",
        .{ task.id, task.target },
    );

    return task;
}

pub fn assignTask(node: Node, task: Task) void {

    std.debug.print(
        "📡 Assigning task {d} → Node {s} | Target: {s}\n",
        .{ task.id, node.id, task.target },
    );
}

pub fn receiveResults(node_id: []const u8, result: []const u8) void {

    std.debug.print(
        "📥 Result received from {s}\n",
        .{node_id},
    );

    std.debug.print(
        "🔍 Finding: {s}\n",
        .{result},
    );
}

pub fn distributeExample() void {

    const node = registerNode("192.168.1.10");

    const task = createTask("example.com");

    assignTask(node, task);

    receiveResults(node.id, "rust malware indicator detected");
}