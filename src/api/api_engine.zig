const std = @import("std");

const Rest = @import("rest_api.zig");
const Stream = @import("stream_server.zig");

pub fn startAPIEngine() void {

    std.log.info(
        "CyberDudeBivash Global Threat Intelligence API Engine Started",
        .{},
    );

    Rest.startAPI();

    Stream.startStream();
}