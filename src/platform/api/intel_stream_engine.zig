const std = @import("std");

const API = @import("intel_api_server.zig");
const Publisher = @import("intel_stream_publisher.zig");

const Types = @import("intel_api_types.zig");
const StreamTypes = @import("intel_stream_types.zig");

pub fn run() void {

    const events = [_]Types.IntelEvent{
        .{
            .indicator = "CVE-2026-XXXX",
            .category = "exploit",
            .confidence = 85,
        },
    };

    API.serve(&events);

    const stream_events = [_]StreamTypes.StreamEvent{
        .{
            .topic = "threat_feed",
            .payload = "exploit_activity_detected",
        },
    };

    Publisher.publish(&stream_events);
}