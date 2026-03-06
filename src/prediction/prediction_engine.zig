const std = @import("std");

const Model = @import("prediction_model.zig");
const GraphStore = @import("../intel_graph/graph_store.zig").GraphStore;
const Analyzer = @import("path_analyzer.zig");

pub fn runPrediction(
    allocator: std.mem.Allocator,
    store: *GraphStore,
    event: []const u8,
) !void {

    _ = allocator;

    const prediction = Model.predict(event);

    if (prediction) |p| {

        std.log.warn(
            "Predicted Attack Campaign: {s}",
            .{p.campaign},
        );

        std.log.warn(
            "Likely Malware: {s}",
            .{p.malware},
        );

        std.log.warn(
            "Likely Vulnerability Exploit: {s}",
            .{p.vulnerability},
        );
    }

    Analyzer.analyzePaths(store);
}