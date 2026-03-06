const std = @import("std");

const Scanner = @import("target_scanner.zig");
const Fuzzer = @import("fuzz_engine.zig");
const Analyzer = @import("exploit_pattern_analyzer.zig");

pub fn runDiscoveryLab() void {

    std.log.info(
        "CyberDudeBivash AI Vulnerability Discovery Lab Activated",
        .{},
    );

    Scanner.scanTargets();

    Fuzzer.runFuzzing("API Gateway");

    Analyzer.analyzeExploitability("API Gateway");
}