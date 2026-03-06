const std = @import("std");

pub const AlertSeverity = enum {
    info,
    low,
    medium,
    high,
    critical,
};

pub const AlertType = enum {
    threat_detected,
    campaign_detected,
    actor_attributed,
    risk_escalation,
    cyber_war_mode,
    defense_action,
};

pub const SOCAlert = struct {
    id: u64,
    alert_type: AlertType,
    severity: AlertSeverity,
    message: []const u8,
    timestamp: i64,
};

pub const IncidentStatus = enum {
    open,
    investigating,
    mitigated,
    closed,
};

pub const IncidentRecord = struct {
    id: u64,
    title: []const u8,
    severity: AlertSeverity,
    status: IncidentStatus,
    created_at: i64,
};

pub const SOCCommandCenter = struct {
    allocator: std.mem.Allocator,

    alerts: std.ArrayList(SOCAlert),
    incidents: std.ArrayList(IncidentRecord),

    next_alert_id: u64,
    next_incident_id: u64,

    pub fn init(allocator: std.mem.Allocator) SOCCommandCenter {
        return SOCCommandCenter{
            .allocator = allocator,
            .alerts = std.ArrayList(SOCAlert).init(allocator),
            .incidents = std.ArrayList(IncidentRecord).init(allocator),
            .next_alert_id = 1,
            .next_incident_id = 1,
        };
    }

    pub fn deinit(self: *SOCCommandCenter) void {
        self.alerts.deinit();
        self.incidents.deinit();
    }

    pub fn createAlert(
        self: *SOCCommandCenter,
        alert_type: AlertType,
        severity: AlertSeverity,
        message: []const u8,
    ) !void {

        const id = self.next_alert_id;
        self.next_alert_id += 1;

        const now = std.time.timestamp();

        try self.alerts.append(.{
            .id = id,
            .alert_type = alert_type,
            .severity = severity,
            .message = message,
            .timestamp = now,
        });
    }

    pub fn createIncident(
        self: *SOCCommandCenter,
        title: []const u8,
        severity: AlertSeverity,
    ) !u64 {

        const id = self.next_incident_id;
        self.next_incident_id += 1;

        const now = std.time.timestamp();

        try self.incidents.append(.{
            .id = id,
            .title = title,
            .severity = severity,
            .status = .open,
            .created_at = now,
        });

        return id;
    }

    pub fn updateIncidentStatus(
        self: *SOCCommandCenter,
        incident_id: u64,
        status: IncidentStatus,
    ) void {

        for (self.incidents.items) |*incident| {

            if (incident.id == incident_id) {
                incident.status = status;
                return;
            }
        }
    }

    pub fn getAlerts(self: *SOCCommandCenter) []SOCAlert {
        return self.alerts.items;
    }

    pub fn getIncidents(self: *SOCCommandCenter) []IncidentRecord {
        return self.incidents.items;
    }

    pub fn alertCount(self: *SOCCommandCenter) usize {
        return self.alerts.items.len;
    }

    pub fn incidentCount(self: *SOCCommandCenter) usize {
        return self.incidents.items.len;
    }

    pub fn clearAlerts(self: *SOCCommandCenter) void {
        self.alerts.clearRetainingCapacity();
    }

    pub fn clearIncidents(self: *SOCCommandCenter) void {
        self.incidents.clearRetainingCapacity();
    }
};