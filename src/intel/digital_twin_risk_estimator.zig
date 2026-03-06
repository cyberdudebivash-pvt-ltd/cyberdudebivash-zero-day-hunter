const std = @import("std");

const Types = @import("digital_twin_types.zig");
const TwinState = Types.TwinState;
const TwinRisk = Types.TwinRisk;

pub fn estimate(
    states: []TwinState,
) TwinRisk {

    var compromised: u32 = 0;

    for (states) |s| {

        if (s.compromised)
            compromised += 1;
    }

    const risk: u8 =
        if (compromised > 20) 90
        else if (compromised > 10) 70
        else 40;

    return TwinRisk{
        .compromised_assets = compromised,
        .risk_score = risk,
    };
}