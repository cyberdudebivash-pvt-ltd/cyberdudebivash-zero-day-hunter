const std = @import("std");

pub const NodeStatus = enum {
    online,
    busy,
    offline,
};

pub const Node = struct {
    id: []const u8,
    ip: []const u8,
    last_seen: i64,
    status: NodeStatus,
};

pub const Task = struct {
    id: u64,
    target: []const u8,
    assigned_node: ?[]const u8,
};

var allocator = std.heap.page_allocator;

var nodes = std.StringHashMap(Node).init(allocator);
var tasks = std.ArrayList(Task).init(allocator);

var task_counter: u64 = 0;

pub fn registerNode(id: []const u8, ip: []const u8) !void {

    const now = std.time.timestamp();

    const node = Node{
        .id = id,
        .ip = ip,
        .last_seen = now,
        .status = .online,
    };

    try nodes.put(id, node);

    std.debug.print(
        "🖥 Node registered: {s} ({s})\n",
        .{ id, ip },
    );
}

pub fn heartbeat(id: []const u8) void {

    if (nodes.getPtr(id)) |node| {

        node.last_seen = std.time.timestamp();
        node.status = .online;

        std.debug.print(
            "💓 Node heartbeat received: {s}\n",
            .{ id },
        );
    }
}

pub fn submitTask(target: []const u8) !void {

    task_counter += 1;

    try tasks.append(.{
        .id = task_counter,
        .target = target,
        .assigned_node = null,
    });

    std.debug.print(
        "📡 New scan task queued: {s}\n",
        .{ target },
    );
}

pub fn scheduleTasks() void {

    if (nodes.count() == 0 or tasks.items.len == 0) return;

    std.debug.print(
        "\n⚙ Scheduling distributed scan tasks\n",
        .{},
    );

    var node_iter = nodes.iterator();

    for (tasks.items) |*task| {

        if (task.assigned_node != null) continue;

        if (!node_iter.next()) {
            node_iter = nodes.iterator();
            _ = node_iter.next();
        }

        const entry = node_iter.next() orelse break;

        const node = entry.value_ptr.*;

        task.assigned_node = node.id;

        std.debug.print(
            "📤 Task #{d} → {s} assigned to node {s}\n",
            .{ task.id, task.target, node.id },
        );
    }
}

pub fn markNodeBusy(node_id: []const u8) void {

    if (nodes.getPtr(node_id)) |node| {

        node.status = .busy;
    }
}

pub fn markNodeOnline(node_id: []const u8) void {

    if (nodes.getPtr(node_id)) |node| {

        node.status = .online;
    }
}

pub fn detectOfflineNodes(timeout_seconds: i64) void {

    const now = std.time.timestamp();

    var it = nodes.iterator();

    while (it.next()) |entry| {

        const node = entry.value_ptr;

        if (now - node.last_seen > timeout_seconds) {

            node.status = .offline;

            std.debug.print(
                "⚠ Node offline: {s}\n",
                .{ node.id },
            );
        }
    }
}

pub fn clusterReport() void {

    std.debug.print(
        "\n🛰 CyberDudeBivash Cluster Status\n",
        .{},
    );

    var it = nodes.iterator();

    while (it.next()) |entry| {

        const node = entry.value_ptr;

        std.debug.print(
            "Node: {s} | IP: {s} | Status: {s}\n",
            .{
                node.id,
                node.ip,
                statusToString(node.status),
            },
        );
    }
}

fn statusToString(status: NodeStatus) []const u8 {

    return switch (status) {
        .online => "online",
        .busy => "busy",
        .offline => "offline",
    };
}

pub fn ingestResult(node_id: []const u8, target: []const u8) void {

    std.debug.print(
        "📥 Result received from node {s} for target {s}\n",
        .{ node_id, target },
    );
}