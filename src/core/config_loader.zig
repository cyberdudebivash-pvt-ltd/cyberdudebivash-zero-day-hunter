const std = @import("std");

pub const PlatformConfig = struct {

    max_threads: usize,
    max_tasks: usize,
    max_memory_bytes: usize,

    enable_plugins: bool,
    enable_ai_reasoning: bool,
    enable_global_exchange: bool,

    plugin_directory: []const u8,
    report_directory: []const u8,
};

pub const ConfigLoader = struct {

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ConfigLoader {
        return ConfigLoader{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ConfigLoader) void {
        _ = self;
    }

    /// Load configuration from JSON file
    pub fn load(
        self: *ConfigLoader,
        path: []const u8,
    ) !PlatformConfig {

        std.log.info(
            "⚙️ Loading platform configuration from {s}",
            .{path},
        );

        var file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const file_size = try file.getEndPos();

        const buffer = try self.allocator.alloc(u8, file_size);
        defer self.allocator.free(buffer);

        _ = try file.readAll(buffer);

        var parsed = try std.json.parseFromSlice(
            std.json.Value,
            self.allocator,
            buffer,
            .{},
        );
        defer parsed.deinit();

        const root = parsed.value;

        const config = PlatformConfig{

            .max_threads =
                root.object.get("max_threads").?.integer,

            .max_tasks =
                root.object.get("max_tasks").?.integer,

            .max_memory_bytes =
                root.object.get("max_memory_bytes").?.integer,

            .enable_plugins =
                root.object.get("enable_plugins").?.bool,

            .enable_ai_reasoning =
                root.object.get("enable_ai_reasoning").?.bool,

            .enable_global_exchange =
                root.object.get("enable_global_exchange").?.bool,

            .plugin_directory =
                root.object.get("plugin_directory").?.string,

            .report_directory =
                root.object.get("report_directory").?.string,
        };

        std.log.info(
            "✅ Configuration loaded successfully",
            .{},
        );

        return config;
    }

    /// Load default configuration if file missing
    pub fn defaultConfig() PlatformConfig {

        return PlatformConfig{

            .max_threads = 8,
            .max_tasks = 500,
            .max_memory_bytes = 512 * 1024 * 1024,

            .enable_plugins = true,
            .enable_ai_reasoning = true,
            .enable_global_exchange = true,

            .plugin_directory = "plugins",
            .report_directory = "reports",
        };
    }

    /// Validate configuration values
    pub fn validate(config: PlatformConfig) !void {

        if (config.max_threads == 0)
            return error.InvalidThreadConfiguration;

        if (config.max_tasks == 0)
            return error.InvalidTaskConfiguration;

        if (config.max_memory_bytes == 0)
            return error.InvalidMemoryConfiguration;

        std.log.info(
            "🔍 Configuration validation successful",
            .{},
        );
    }
};