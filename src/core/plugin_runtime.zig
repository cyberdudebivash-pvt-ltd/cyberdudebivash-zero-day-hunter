const std = @import("std");

pub const Plugin = struct {
    name: []const u8,
    path: []const u8,
};

pub const PluginRuntime = struct {

    allocator: std.mem.Allocator,

    plugins: std.ArrayList(Plugin),

    pub fn init(allocator: std.mem.Allocator) PluginRuntime {

        return PluginRuntime{
            .allocator = allocator,
            .plugins = std.ArrayList(Plugin).init(allocator),
        };
    }

    pub fn deinit(self: *PluginRuntime) void {
        self.plugins.deinit();
    }

    /// Discover plugins inside plugins directory
    pub fn discover(
        self: *PluginRuntime,
        plugin_dir: []const u8,
    ) !void {

        std.log.info(
            "🔎 Discovering plugins in {s}",
            .{plugin_dir},
        );

        var cwd = std.fs.cwd();

        var dir = try cwd.openDir(plugin_dir, .{ .iterate = true });
        defer dir.close();

        var it = dir.iterate();

        while (try it.next()) |entry| {

            if (entry.kind != .file)
                continue;

            if (!std.mem.endsWith(u8, entry.name, ".so"))
                continue;

            const plugin = Plugin{
                .name = entry.name,
                .path = entry.name,
            };

            try self.plugins.append(plugin);

            std.log.info(
                "🔌 Plugin discovered: {s}",
                .{entry.name},
            );
        }

        std.log.info(
            "📦 Total plugins discovered: {}",
            .{self.plugins.items.len},
        );
    }

    /// Load all plugins
    pub fn loadAll(
        self: *PluginRuntime,
        plugin_dir: []const u8,
    ) !void {

        std.log.info(
            "⚙️ Loading {} plugins",
            .{self.plugins.items.len},
        );

        for (self.plugins.items) |plugin| {

            const full_path = try std.fmt.allocPrint(
                self.allocator,
                "{s}/{s}",
                .{ plugin_dir, plugin.path },
            );
            defer self.allocator.free(full_path);

            try self.loadPlugin(full_path);
        }

        std.log.info(
            "✅ Plugin runtime initialization complete",
            .{},
        );
    }

    /// Load a single plugin
    fn loadPlugin(
        self: *PluginRuntime,
        path: []const u8,
    ) !void {

        std.log.info(
            "🔌 Loading plugin: {s}",
            .{path},
        );

        var lib = try std.DynLib.open(path);
        defer lib.close();

        const entry_fn = lib.lookup(
            fn () void,
            "plugin_entry",
        ) catch {

            std.log.warn(
                "⚠️ Plugin missing entry function: {s}",
                .{path},
            );

            return;
        };

        std.log.info(
            "▶ Executing plugin entry",
            .{},
        );

        entry_fn();
    }

    /// Execute plugin hooks
    pub fn executeHooks(self: *PluginRuntime) void {

        std.log.info(
            "🧩 Executing plugin hooks",
            .{},
        );

        for (self.plugins.items) |plugin| {

            std.log.info(
                "🔧 Plugin active: {s}",
                .{plugin.name},
            );
        }
    }
};