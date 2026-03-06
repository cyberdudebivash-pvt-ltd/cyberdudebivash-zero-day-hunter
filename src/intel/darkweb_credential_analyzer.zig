const std = @import("std");
const Types = @import("darkweb_types.zig");

const CredentialLeak = Types.CredentialLeak;

pub fn analyze_credentials(
    allocator: std.mem.Allocator,
    leaks: []CredentialLeak,
) !u32 {

    var total: u32 = 0;

    for (leaks) |l| {
        total += l.record_count;
    }

    return total;
}