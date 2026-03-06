const std = @import("std");
const Types = @import("intel_api_types.zig");

const IntelEvent = Types.IntelEvent;

pub fn serve(events: []IntelEvent) void {

    std.log.info("CYBERDUDEBIVASH Threat Intel API started", .{});

    for (events) |e| {

        std.log.info(
            "intel_event indicator={s} category={s} confidence={}",
            .{ e.indicator, e.category, e.confidence },
        );
    }
}