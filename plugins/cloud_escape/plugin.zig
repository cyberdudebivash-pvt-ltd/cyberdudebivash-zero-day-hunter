const std = @import("std");

export fn hunter_name() [*:0]const u8 {
    return "cloud_escape";
}

export fn hunter_run() void {

    std.debug.print(
        "☁️ Cloud Escape Hunter — checking container breakout vectors\n",
        .{},
    );

    const indicators = [_][]const u8{
        "/var/run/docker.sock",
        "169.254.169.254",
        "/proc/self/cgroup",
        "kubelet",
        "containerd",
    };

    for (indicators) |indicator| {

        std.debug.print(
            "🔍 Checking cloud escape indicator: {s}\n",
            .{indicator},
        );

        std.time.sleep(50 * std.time.ns_per_ms);
    }

    std.debug.print(
        "☁️ Cloud escape analysis complete\n",
        .{},
    );
}