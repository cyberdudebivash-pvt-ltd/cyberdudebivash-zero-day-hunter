const std = @import("std");

const StreamEvent = @import("intel_stream_types.zig").StreamEvent;

pub fn publish(events: []StreamEvent) void {

    for (events) |e| {

        std.log.info(
            "stream_event topic={s} payload={s}",
            .{ e.topic, e.payload },
        );
    }
}