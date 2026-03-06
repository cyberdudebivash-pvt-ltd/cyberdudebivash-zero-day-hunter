const std = @import("std");

const Collector = @import("vuln_code_collector.zig");
const PatternEngine = @import("vuln_pattern_engine.zig");
const Analyzer = @import("vuln_ai_analyzer.zig");
const Generator = @import("vuln_candidate_generator.zig");

pub fn run(
    allocator: std.mem.Allocator,
) !void {

    const samples = try Collector.collect(allocator);

    const patterns = PatternEngine.patterns();

    const results = try Analyzer.analyze(
        allocator,
        samples,
        patterns,
    );

    Generator.generate(results);

    std.log.info(
        "AI vulnerability discovery lab executed samples={}",
        .{ samples.len },
    );
}