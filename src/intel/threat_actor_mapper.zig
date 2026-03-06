const std = @import("std");

/// Known threat actor
pub const ThreatActor = struct {
    name: []const u8,
    aliases: []const []const u8,
    description: []const u8,
};

/// Intelligence indicator linked to actors
pub const ActorIndicator = struct {
    indicator: []const u8,
    actor_index: usize,
};

/// Attribution result
pub const Attribution = struct {
    target: []const u8,
    actor: []const u8,
    confidence: u8,
};

/// Threat Actor Mapper Engine
pub const ThreatActorMapper = struct {

    allocator: std.mem.Allocator,

    actors: std.ArrayList(ThreatActor),
    indicators: std.ArrayList(ActorIndicator),

    /// ------------------------------------------------
    /// INIT
    /// ------------------------------------------------
    pub fn init(allocator: std.mem.Allocator) ThreatActorMapper {
        return .{
            .allocator = allocator,
            .actors = std.ArrayList(ThreatActor).init(allocator),
            .indicators = std.ArrayList(ActorIndicator).init(allocator),
        };
    }

    /// ------------------------------------------------
    /// DEINIT
    /// ------------------------------------------------
    pub fn deinit(self: *ThreatActorMapper) void {

        for (self.actors.items) |actor| {
            self.allocator.free(actor.name);
            self.allocator.free(actor.description);
        }

        for (self.indicators.items) |indicator| {
            self.allocator.free(indicator.indicator);
        }

        self.actors.deinit();
        self.indicators.deinit();
    }

    /// ------------------------------------------------
    /// REGISTER ACTOR
    /// ------------------------------------------------
    pub fn addActor(
        self: *ThreatActorMapper,
        name: []const u8,
        description: []const u8,
        aliases: []const []const u8,
    ) !usize {

        const name_dup = try self.allocator.dupe(u8, name);
        const desc_dup = try self.allocator.dupe(u8, description);

        try self.actors.append(.{
            .name = name_dup,
            .description = desc_dup,
            .aliases = aliases,
        });

        const index = self.actors.items.len - 1;

        std.log.info(
            "[ThreatActorMapper] Registered actor: {s}",
            .{name_dup},
        );

        return index;
    }

    /// ------------------------------------------------
    /// ADD INDICATOR
    /// ------------------------------------------------
    pub fn addIndicator(
        self: *ThreatActorMapper,
        indicator: []const u8,
        actor_index: usize,
    ) !void {

        const dup = try self.allocator.dupe(u8, indicator);

        try self.indicators.append(.{
            .indicator = dup,
            .actor_index = actor_index,
        });

        std.log.info(
            "[ThreatActorMapper] Indicator linked: {s}",
            .{dup},
        );
    }

    /// ------------------------------------------------
    /// FIND ACTOR BY INDICATOR
    /// ------------------------------------------------
    fn lookup(
        self: *ThreatActorMapper,
        indicator: []const u8,
    ) ?usize {

        for (self.indicators.items) |item| {
            if (std.mem.eql(u8, item.indicator, indicator)) {
                return item.actor_index;
            }
        }

        return null;
    }

    /// ------------------------------------------------
    /// ATTRIBUTION ENGINE
    /// ------------------------------------------------
    pub fn attribute(
        self: *ThreatActorMapper,
        target: []const u8,
        indicator: []const u8,
    ) ?Attribution {

        const actor_index = self.lookup(indicator) orelse return null;

        const actor = self.actors.items[actor_index];

        return Attribution{
            .target = target,
            .actor = actor.name,
            .confidence = 75,
        };
    }

    /// ------------------------------------------------
    /// LOAD BUILTIN ACTORS
    /// ------------------------------------------------
    pub fn loadBuiltinActors(self: *ThreatActorMapper) !void {

        const apt28 = try self.addActor(
            "APT28",
            "Russian state-sponsored threat actor also known as Fancy Bear",
            &[_][]const u8{ "FancyBear", "Sofacy" },
        );

        const lazarus = try self.addActor(
            "Lazarus Group",
            "North Korean cyber espionage and financial threat group",
            &[_][]const u8{ "Hidden Cobra" },
        );

        try self.addIndicator("sofacy-domain", apt28);
        try self.addIndicator("lazarus-malware", lazarus);

        std.log.info(
            "[ThreatActorMapper] Built-in threat actors loaded",
            .{},
        );
    }

    /// ------------------------------------------------
    /// SOC OUTPUT
    /// ------------------------------------------------
    pub fn emit(self: *ThreatActorMapper, attribution: Attribution) void {

        std.log.warn(
            "[Attribution] target={s} actor={s} confidence={}%",
            .{ attribution.target, attribution.actor, attribution.confidence },
        );

        _ = self;
    }
};