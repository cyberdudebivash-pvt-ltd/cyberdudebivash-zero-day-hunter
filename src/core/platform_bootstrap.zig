const std = @import("std");

const ResourceManager = @import("resource_manager.zig").ResourceManager;
const RuntimeScheduler = @import("runtime_scheduler.zig").RuntimeScheduler;
const PluginRuntime = @import("plugin_runtime.zig").PluginRuntime;

pub const PlatformBootstrap = struct {

    allocator: std.mem.Allocator,

    resource_manager: ResourceManager,
    scheduler: RuntimeScheduler,
    plugin_runtime: PluginRuntime,

    pub fn init(
        allocator: std.mem.Allocator,
    ) !PlatformBootstrap {

        std.log.info(
            "🚀 Initializing CYBERDUDEBIVASH Platform Bootstrap",
            .{},
        );

        //-----------------------------------
        // Resource Limits
        //-----------------------------------

        const limits = ResourceManager.ResourceLimits{
            .max_threads = 16,
            .max_tasks = 1000,
            .max_memory_bytes = 1024 * 1024 * 1024,
        };

        var resource_manager = ResourceManager.init(
            allocator,
            limits,
        );

        //-----------------------------------
        // Scheduler
        //-----------------------------------

        var scheduler = RuntimeScheduler.init(
            allocator,
            8,
        );

        //-----------------------------------
        // Plugin Runtime
        //-----------------------------------

        var plugin_runtime = PluginRuntime.init(
            allocator,
        );

        std.log.info(
            "✅ Platform bootstrap initialization complete",
            .{},
        );

        return PlatformBootstrap{
            .allocator = allocator,
            .resource_manager = resource_manager,
            .scheduler = scheduler,
            .plugin_runtime = plugin_runtime,
        };
    }

    pub fn deinit(self: *PlatformBootstrap) void {

        std.log.info(
            "🛑 Shutting down platform bootstrap",
            .{},
        );

        self.scheduler.deinit();
        self.plugin_runtime.deinit();
    }

    /// Validate runtime environment
    pub fn validateEnvironment(self: *PlatformBootstrap) !void {

        _ = self;

        std.log.info(
            "🔍 Validating runtime environment",
            .{},
        );

        var cwd = std.fs.cwd();

        // Ensure plugins directory exists
        cwd.openDir("plugins", .{}) catch {
            std.log.warn(
                "⚠️ Plugins directory missing",
                .{},
            );
        };

        // Ensure reports directory exists
        cwd.makeDir("reports") catch {};

        std.log.info(
            "✅ Environment validation complete",
            .{},
        );
    }

    /// Load plugins before engine execution
    pub fn initializePlugins(self: *PlatformBootstrap) !void {

        std.log.info(
            "🔌 Initializing plugin runtime",
            .{},
        );

        try self.plugin_runtime.discover("plugins");
        try self.plugin_runtime.loadAll("plugins");
    }

    /// Display platform startup status
    pub fn startupStatus(self: *PlatformBootstrap) void {

        std.log.info(
            "📊 Platform Runtime Status",
            .{},
        );

        self.resource_manager.status();

        std.log.info(
            "Scheduler workers ready",
            .{},
        );

        std.log.info(
            "Plugin runtime initialized",
            .{},
        );
    }
};