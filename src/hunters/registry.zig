const std = @import("std");

const HunterInterface = @import("interface.zig").HunterInterface;
const HunterResult = @import("interface.zig").HunterResult;

pub const HunterRegistry = struct {

    allocator: std.mem.Allocator,
    hunters: std.ArrayList(HunterInterface),

    /// Initialize registry
    pub fn init(allocator: std.mem.Allocator) HunterRegistry {
        return .{
            .allocator = allocator,
            .hunters = std.ArrayList(HunterInterface).init(allocator),
        };
    }

    /// Destroy registry
    pub fn deinit(self: *HunterRegistry) void {
        self.hunters.deinit();
    }

    /// Register a hunter module
    pub fn register(self: *HunterRegistry, hunter: HunterInterface) !void {

        try self.hunters.append(hunter);

        std.log.info(
            "[HunterRegistry] Registered hunter: {s}",
            .{hunter.name},
        );
    }

    /// Find hunter by name
    pub fn get(
        self: *HunterRegistry,
        name: []const u8,
    ) ?*const HunterInterface {

        for (self.hunters.items) |*hunter| {
            if (std.mem.eql(u8, hunter.name, name)) {
                return hunter;
            }
        }

        return null;
    }

    /// Execute a single hunter
    pub fn runHunter(
        self: *HunterRegistry,
        allocator: std.mem.Allocator,
        name: []const u8,
        target: []const u8,
    ) !void {

        const hunter = self.get(name) orelse {
            std.log.err(
                "[HunterRegistry] Hunter not found: {s}",
                .{name},
            );
            return error.HunterNotFound;
        };

        std.log.info(
            "[HunterRegistry] Executing hunter: {s}",
            .{hunter.name},
        );

        var result = try hunter.run(allocator, target);
        defer result.clean(allocator);

        if (result.detected) {
            std.log.warn(
                "[THREAT DETECTED] {s} severity={}",
                .{ result.title, result.severity },
            );
        } else {
            std.log.info(
                "[HunterRegistry] No threat detected by {s}",
                .{hunter.name},
            );
        }
    }

    /// Execute all registered hunters
    pub fn runAll(
        self: *HunterRegistry,
        allocator: std.mem.Allocator,
        target: []const u8,
    ) !void {

        if (self.hunters.items.len == 0) {
            std.log.warn(
                "[HunterRegistry] No hunters registered.",
                .{},
            );
            return;
        }

        for (self.hunters.items) |*hunter| {

            std.log.info(
                "[HunterRegistry] Running hunter: {s}",
                .{hunter.name},
            );

            var result = try hunter.run(allocator, target);
            defer result.clean(allocator);

            if (result.detected) {
                std.log.warn(
                    "[THREAT DETECTED] {s} severity={}",
                    .{ result.title, result.severity },
                );
            } else {
                std.log.info(
                    "[HunterRegistry] No threat detected by {s}",
                    .{hunter.name},
                );
            }
        }
    }

    /// Count registered hunters
    pub fn count(self: *HunterRegistry) usize {
        return self.hunters.items.len;
    }

    /// List hunters for SOC visibility
    pub fn list(self: *HunterRegistry) void {

        std.log.info(
            "[HunterRegistry] Listing hunters:",
            .{},
        );

        for (self.hunters.items) |hunter| {
            std.log.info(
                " - {s} ({s}) v{s}",
                .{ hunter.name, hunter.category, hunter.version },
            );
        }
    }
};