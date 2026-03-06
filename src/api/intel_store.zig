const std = @import("std");
const IntelEvent = @import("intel_event.zig").IntelEvent;

pub const IntelStore = struct {

    events: std.ArrayList(IntelEvent),

    pub fn init(allocator: std.mem.Allocator) IntelStore {
        return IntelStore{
            .events = std.ArrayList(IntelEvent).init(allocator),
        };
    }

    pub fn addEvent(
        self: *IntelStore,
        event: IntelEvent,
    ) !void {

        try self.events.append(event);
    }
};