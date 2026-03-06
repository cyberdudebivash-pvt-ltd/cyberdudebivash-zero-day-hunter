const std = @import("std");

pub const DashboardMetrics = struct {
    active_incidents: u32,
    critical_alerts: u32,
    high_alerts: u32,
    global_risk_score: f32,
    cyber_war_mode: bool,
    timestamp: i64,
};

pub const AlertSummary = struct {
    id: u64,
    severity: []const u8,
    message: []const u8,
    timestamp: i64,
};

pub const IncidentSummary = struct {
    id: u64,
    title: []const u8,
    severity: []const u8,
    status: []const u8,
    created_at: i64,
};

pub const DashboardAPI = struct {
    allocator: std.mem.Allocator,

    metrics: DashboardMetrics,

    alerts: std.ArrayList(AlertSummary),
    incidents: std.ArrayList(IncidentSummary),

    pub fn init(allocator: std.mem.Allocator) DashboardAPI {
        return DashboardAPI{
            .allocator = allocator,
            .metrics = DashboardMetrics{
                .active_incidents = 0,
                .critical_alerts = 0,
                .high_alerts = 0,
                .global_risk_score = 0,
                .cyber_war_mode = false,
                .timestamp = std.time.timestamp(),
            },
            .alerts = std.ArrayList(AlertSummary).init(allocator),
            .incidents = std.ArrayList(IncidentSummary).init(allocator),
        };
    }

    pub fn deinit(self: *DashboardAPI) void {
        self.alerts.deinit();
        self.incidents.deinit();
    }

    pub fn updateMetrics(
        self: *DashboardAPI,
        active_incidents: u32,
        critical_alerts: u32,
        high_alerts: u32,
        global_risk_score: f32,
        cyber_war_mode: bool,
    ) void {

        self.metrics = DashboardMetrics{
            .active_incidents = active_incidents,
            .critical_alerts = critical_alerts,
            .high_alerts = high_alerts,
            .global_risk_score = global_risk_score,
            .cyber_war_mode = cyber_war_mode,
            .timestamp = std.time.timestamp(),
        };
    }

    pub fn addAlert(
        self: *DashboardAPI,
        id: u64,
        severity: []const u8,
        message: []const u8,
        timestamp: i64,
    ) !void {

        try self.alerts.append(.{
            .id = id,
            .severity = severity,
            .message = message,
            .timestamp = timestamp,
        });
    }

    pub fn addIncident(
        self: *DashboardAPI,
        id: u64,
        title: []const u8,
        severity: []const u8,
        status: []const u8,
        created_at: i64,
    ) !void {

        try self.incidents.append(.{
            .id = id,
            .title = title,
            .severity = severity,
            .status = status,
            .created_at = created_at,
        });
    }

    pub fn getMetrics(self: *DashboardAPI) DashboardMetrics {
        return self.metrics;
    }

    pub fn getAlerts(self: *DashboardAPI) []AlertSummary {
        return self.alerts.items;
    }

    pub fn getIncidents(self: *DashboardAPI) []IncidentSummary {
        return self.incidents.items;
    }

    pub fn alertsCount(self: *DashboardAPI) usize {
        return self.alerts.items.len;
    }

    pub fn incidentsCount(self: *DashboardAPI) usize {
        return self.incidents.items.len;
    }

    pub fn clearAlerts(self: *DashboardAPI) void {
        self.alerts.clearRetainingCapacity();
    }

    pub fn clearIncidents(self: *DashboardAPI) void {
        self.incidents.clearRetainingCapacity();
    }

    pub fn exportMetricsJSON(self: *DashboardAPI, writer: anytype) !void {

        try writer.print(
            "{{\"active_incidents\":{},\"critical_alerts\":{},\"high_alerts\":{},\"global_risk\":{d:.2},\"cyber_war_mode\":{},\"timestamp\":{}}}",
            .{
                self.metrics.active_incidents,
                self.metrics.critical_alerts,
                self.metrics.high_alerts,
                self.metrics.global_risk_score,
                self.metrics.cyber_war_mode,
                self.metrics.timestamp,
            },
        );
    }
};