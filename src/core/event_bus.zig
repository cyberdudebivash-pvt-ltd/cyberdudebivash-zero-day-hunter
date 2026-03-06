// ============================================================================
// CYBERDUDEBIVASH ZERO-DAY HUNTER™ — EVENT BUS
// Central Nervous System of the Platform
//
// All subsystems communicate through this bus.
// Implements typed pub/sub with priority queuing.
//
// (c) CyberDudeBivash Pvt. Ltd.
// ============================================================================

const std = @import("std");

// ──────────────────────────────────────────────
// EVENT TYPES
// ──────────────────────────────────────────────

pub const EventType = enum {
    // Telemetry
    TELEMETRY_RECEIVED,
    TELEMETRY_NORMALIZED,

    // Detection
    RULE_MATCH,
    SIGMA_MATCH,
    YARA_MATCH,
    IOC_DISCOVERED,

    // Threat Intelligence
    SIGNAL_CORRELATED,
    THREAT_GRAPH_UPDATED,
    ATTACK_CHAIN_IDENTIFIED,
    CAMPAIGN_DETECTED,
    THREAT_ACTOR_ATTRIBUTED,

    // Botnet
    BOTNET_ACTIVITY,
    BOTNET_C2_DISCOVERED,

    // Zero-Day
    ZERO_DAY_SIGNAL,
    ZERO_DAY_CONFIRMED,

    // Defense
    DEFENSE_ACTION_TRIGGERED,
    DEFENSE_ACTION_COMPLETED,
    COUNTERMEASURE_DEPLOYED,

    // Risk
    RISK_SCORE_UPDATED,
    RISK_THRESHOLD_EXCEEDED,

    // Platform
    ENGINE_STARTED,
    ENGINE_STOPPED,
    ENGINE_ERROR,
    HEALTH_CHECK,
    PLUGIN_LOADED,

    // SOC
    SOC_ALERT,
    SOC_INCIDENT,

    // AI
    AI_PREDICTION,
    AI_DEFENSE_RECOMMENDATION,
};

pub const EventPriority = enum(u8) {
    low = 0,
    medium = 1,
    high = 2,
    critical = 3,
};

// ──────────────────────────────────────────────
// EVENT STRUCTURE
// ──────────────────────────────────────────────

pub const Event = struct {
    id: u64,
    event_type: EventType,
    priority: EventPriority,
    source: []const u8,
    payload: []const u8,
    timestamp: i64,
};

// ──────────────────────────────────────────────
// SUBSCRIBER CALLBACK
// ──────────────────────────────────────────────

pub const SubscriberFn = *const fn (event: *const Event) void;

const Subscription = struct {
    event_type: EventType,
    callback: SubscriberFn,
    subscriber_name: []const u8,
};

// ──────────────────────────────────────────────
// EVENT BUS
// ──────────────────────────────────────────────

pub const EventBus = struct {
    allocator: std.mem.Allocator,

    subscriptions: std.ArrayList(Subscription),
    event_queue: std.ArrayList(Event),
    event_log: std.ArrayList(Event),

    next_event_id: u64,
    total_published: u64,
    total_delivered: u64,

    running: bool,
    worker_thread: ?std.Thread,

    mutex: std.Thread.Mutex,

    pub fn init(allocator: std.mem.Allocator) EventBus {
        return EventBus{
            .allocator = allocator,
            .subscriptions = std.ArrayList(Subscription).init(allocator),
            .event_queue = std.ArrayList(Event).init(allocator),
            .event_log = std.ArrayList(Event).init(allocator),
            .next_event_id = 1,
            .total_published = 0,
            .total_delivered = 0,
            .running = false,
            .worker_thread = null,
            .mutex = .{},
        };
    }

    pub fn deinit(self: *EventBus) void {
        self.stop();
        self.subscriptions.deinit();
        self.event_queue.deinit();
        self.event_log.deinit();
    }

    // ─── SUBSCRIBE ────────────────────────────

    pub fn subscribe(
        self: *EventBus,
        event_type: EventType,
        subscriber_name: []const u8,
        callback: SubscriberFn,
    ) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        try self.subscriptions.append(.{
            .event_type = event_type,
            .callback = callback,
            .subscriber_name = subscriber_name,
        });

        std.log.info(
            "[EventBus] {s} subscribed to {s}",
            .{ subscriber_name, @tagName(event_type) },
        );
    }

    // ─── PUBLISH ──────────────────────────────

    pub fn publish(
        self: *EventBus,
        event_type: EventType,
        priority: EventPriority,
        source: []const u8,
        payload: []const u8,
    ) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        const event = Event{
            .id = self.next_event_id,
            .event_type = event_type,
            .priority = priority,
            .source = source,
            .payload = payload,
            .timestamp = std.time.timestamp(),
        };

        self.next_event_id += 1;
        self.total_published += 1;

        try self.event_queue.append(event);
        try self.event_log.append(event);

        // Keep log bounded
        if (self.event_log.items.len > 10000) {
            _ = self.event_log.orderedRemove(0);
        }
    }

    // ─── DISPATCH (process queue) ─────────────

    pub fn dispatch(self: *EventBus) void {
        self.mutex.lock();

        if (self.event_queue.items.len == 0) {
            self.mutex.unlock();
            return;
        }

        // Sort by priority (critical first)
        std.mem.sort(
            Event,
            self.event_queue.items,
            {},
            comparePriority,
        );

        // Copy events to process outside lock
        const events_to_process = self.allocator.alloc(
            Event,
            self.event_queue.items.len,
        ) catch {
            self.mutex.unlock();
            return;
        };
        @memcpy(events_to_process, self.event_queue.items);
        self.event_queue.clearRetainingCapacity();

        // Copy subscriptions for dispatch
        const subs = self.allocator.alloc(
            Subscription,
            self.subscriptions.items.len,
        ) catch {
            self.allocator.free(events_to_process);
            self.mutex.unlock();
            return;
        };
        @memcpy(subs, self.subscriptions.items);

        self.mutex.unlock();

        // Dispatch outside lock
        for (events_to_process) |*event| {
            for (subs) |sub| {
                if (sub.event_type == event.event_type) {
                    sub.callback(event);
                    self.mutex.lock();
                    self.total_delivered += 1;
                    self.mutex.unlock();
                }
            }
        }

        self.allocator.free(events_to_process);
        self.allocator.free(subs);
    }

    fn comparePriority(_: void, a: Event, b: Event) bool {
        return @intFromEnum(a.priority) > @intFromEnum(b.priority);
    }

    // ─── START BACKGROUND DISPATCHER ──────────

    pub fn start(self: *EventBus) !void {
        if (self.running) return;
        self.running = true;

        self.worker_thread = try std.Thread.spawn(
            .{},
            dispatchLoop,
            .{self},
        );

        std.log.info("[EventBus] Dispatch loop started", .{});
    }

    fn dispatchLoop(self: *EventBus) void {
        while (self.running) {
            self.dispatch();
            std.time.sleep(10 * std.time.ns_per_ms);
        }
    }

    pub fn stop(self: *EventBus) void {
        if (!self.running) return;
        self.running = false;

        if (self.worker_thread) |thread| {
            thread.join();
            self.worker_thread = null;
        }

        std.log.info("[EventBus] Dispatch loop stopped", .{});
    }

    // ─── METRICS ──────────────────────────────

    pub fn stats(self: *EventBus) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        std.log.info(
            "[EventBus] published={d} delivered={d} subscribers={d} queued={d}",
            .{
                self.total_published,
                self.total_delivered,
                self.subscriptions.items.len,
                self.event_queue.items.len,
            },
        );
    }

    // ─── QUERY EVENT LOG ──────────────────────

    pub fn getRecentEvents(
        self: *EventBus,
        count: usize,
    ) []const Event {
        self.mutex.lock();
        defer self.mutex.unlock();

        const log = self.event_log.items;
        if (log.len <= count) return log;
        return log[log.len - count ..];
    }

    pub fn getEventsByType(
        self: *EventBus,
        event_type: EventType,
        result_buf: *std.ArrayList(Event),
    ) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        for (self.event_log.items) |event| {
            if (event.event_type == event_type) {
                try result_buf.append(event);
            }
        }
    }
};
