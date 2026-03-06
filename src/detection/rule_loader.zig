const std = @import("std");

const rule_mod = @import("rule.zig");

pub const DEFAULT_RULE_PATH = "rules";

/// Load rules from filesystem
pub fn load(allocator: std.mem.Allocator) !std.ArrayList(rule_mod.Rule) {

    std.log.info("Rule loader started", .{});

    var rules = std.ArrayList(rule_mod.Rule).init(allocator);

    const cwd = std.fs.cwd();

    var dir = cwd.openDir(DEFAULT_RULE_PATH, .{
        .iterate = true,
    }) catch {
        std.log.warn("Rule directory not found: {s}", .{DEFAULT_RULE_PATH});
        return rules;
    };

    defer dir.close();

    var it = dir.iterate();

    while (try it.next()) |entry| {

        if (entry.kind != .file) continue;

        if (!std.mem.endsWith(u8, entry.name, ".rule")) continue;

        const rule = try loadRuleFile(allocator, dir, entry.name);

        try rules.append(rule);
    }

    std.log.info("Total rules loaded: {}", .{rules.items.len});

    return rules;
}

/// Load a single rule file
fn loadRuleFile(
    allocator: std.mem.Allocator,
    dir: std.fs.Dir,
    filename: []const u8,
) !rule_mod.Rule {

    std.log.info("Loading rule: {s}", .{filename});

    var file = try dir.openFile(filename, .{});
    defer file.close();

    const size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    return parseRule(buffer);
}

/// Parse rule definition
fn parseRule(data: []const u8) !rule_mod.Rule {

    var name: []const u8 = "unknown_rule";
    var finding_type: []const u8 = "";
    var severity: ?[]const u8 = null;
    var description: ?[]const u8 = null;

    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {

        const trimmed = std.mem.trim(u8, line, " \t\r");

        if (trimmed.len == 0) continue;

        if (std.mem.startsWith(u8, trimmed, "name=")) {
            name = trimmed[5..];
        }
        else if (std.mem.startsWith(u8, trimmed, "finding_type=")) {
            finding_type = trimmed[13..];
        }
        else if (std.mem.startsWith(u8, trimmed, "severity=")) {
            severity = trimmed[9..];
        }
        else if (std.mem.startsWith(u8, trimmed, "description=")) {
            description = trimmed[12..];
        }
    }

    return validateRule(rule_mod.Rule{
        .name = name,
        .finding_type = finding_type,
        .override_severity = severity,
        .override_description = description,
    });
}

/// Validate rule schema
fn validateRule(rule: rule_mod.Rule) !rule_mod.Rule {

    if (rule.finding_type.len == 0) {
        std.log.warn("Invalid rule: missing finding_type", .{});
    }

    return rule;
}