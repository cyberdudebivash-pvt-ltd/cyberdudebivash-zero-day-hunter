const std = @import("std");

const Types = @import("digital_twin_types.zig");
const TwinState = Types.TwinState;
const TwinAttack = Types.TwinAttack;

pub fn simulate(
    states: []TwinState,
    attacks: []TwinAttack,
) void {

    for (attacks) |a| {

        for (states) |*s| {

            if (std.mem.eql(u8, s.asset_id, a.target)) {

                s.compromised = true;
            }
        }
    }
}