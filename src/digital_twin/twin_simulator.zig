const std = @import("std");

const InfrastructureModel =
    @import("infrastructure_model.zig").InfrastructureModel;

pub fn simulate(
    model: *InfrastructureModel,
) void {

    for (model.assets.items) |asset| {

        std.log.info(
            "Digital Twin Asset: {s}",
            .{asset.hostname},
        );
    }

    std.log.warn(
        "Simulated Attack Path: web_server → database",
        .{},
    );
}