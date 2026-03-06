const std = @import("std");
const verify = @import("plugin_verify.zig");

const c = @cImport({
    @cInclude("dlfcn.h");
});

pub fn loadPlugins(allocator: std.mem.Allocator) !void {

    const plugin_dir = "plugins";

    var cwd = std.fs.cwd();

    var dir = cwd.openDir(plugin_dir, .{ .iterate = true }) catch {
        std.debug.print(
            "⚠️ Plugin directory not found: {s}\n",
            .{plugin_dir},
        );
        return;
    };
    defer dir.close();

    var it = dir.iterate();

    while (try it.next()) |entry| {

        if (entry.kind != .file) continue;

        if (!std.mem.endsWith(u8, entry.name, ".so")) continue;

        const path = try std.fmt.allocPrint(
            allocator,
            "{s}/{s}",
            .{plugin_dir, entry.name},
        );
        defer allocator.free(path);

        std.debug.print(
            "🔌 Loading plugin: {s}\n",
            .{path},
        );

        //------------------------------------------------
        // Signature Verification
        //------------------------------------------------

        const sig_path = try std.fmt.allocPrint(
            allocator,
            "{s}.sig",
            .{path},
        );
        defer allocator.free(sig_path);

        const verified = verify.verifyPlugin(
            allocator,
            path,
            sig_path,
        ) catch false;

        if (!verified) {

            std.debug.print(
                "🚫 Plugin rejected (signature invalid)\n",
                .{},
            );

            continue;
        }

        //------------------------------------------------
        // Dynamic Library Load
        //------------------------------------------------

        const handle = c.dlopen(path.ptr, c.RTLD_NOW);

        if (handle == null) {

            const err = c.dlerror();

            if (err != null) {
                std.debug.print(
                    "❌ dlopen failed: {s}\n",
                    .{std.mem.span(err)},
                );
            }

            continue;
        }

        //------------------------------------------------
        // Resolve symbols
        //------------------------------------------------

        const name_sym = c.dlsym(handle, "hunter_name");
        const run_sym = c.dlsym(handle, "hunter_run");

        if (name_sym == null or run_sym == null) {

            std.debug.print(
                "⚠️ Invalid plugin interface\n",
                .{},
            );

            _ = c.dlclose(handle);
            continue;
        }

        const HunterNameFn =
            *const fn() callconv(.C) [*:0]const u8;

        const HunterRunFn =
            *const fn() callconv(.C) void;

        const hunter_name =
            @as(HunterNameFn, @ptrCast(name_sym));

        const hunter_run =
            @as(HunterRunFn, @ptrCast(run_sym));

        const name = hunter_name();

        std.debug.print(
            "⚙️ Executing plugin: {s}\n",
            .{std.mem.span(name)},
        );

        hunter_run();

        _ = c.dlclose(handle);
    }
}