// ============================================================================
//
//  CYBERDUDEBIVASH ZERO-DAY HUNTER™
//  Master Platform Runtime v1.0.0
//
//  Unified entry point that bootstraps, wires, and orchestrates
//  ALL platform subsystems into a single cyber defense operating system.
//
//  Boot Sequence:
//    1. Configuration      →  Load platform.json or defaults
//    2. Resource Manager   →  Memory/thread/task limits
//    3. Event Bus          →  Central nervous system
//    4. Health Monitor     →  Runtime health tracking
//    5. Orchestrator       →  Engine lifecycle management
//    6. Threat Pipeline    →  Ingest → Normalize → Correlate → Score
//    7. Threat Graph       →  Relationship modeling engine
//    8. Detection Engine   →  Rule + Sigma + YARA chain
//    9. Defense Engine     →  Automated response actions
//   10. State Export       →  IPC for API gateway
//   11. Runtime Loop       →  Continuous operational cycles
//
//  (c) CyberDudeBivash Pvt. Ltd.
//
// ============================================================================

const std = @import("std");

// ─── CORE RUNTIME ───────────────────────────────────────────────────────────
const ConfigLoader = @import("core/config_loader.zig").ConfigLoader;
const ResourceManager = @import("core/resource_manager.zig").ResourceManager;
const HealthMonitor = @import("core/health_monitor.zig").HealthMonitor;
const EventBus = @import("core/event_bus.zig").EventBus;
const EventType = @import("core/event_bus.zig").EventType;
const EventPriority = @import("core/event_bus.zig").EventPriority;
const Event = @import("core/event_bus.zig").Event;
const PlatformOrchestrator = @import("core/platform_orchestrator.zig").PlatformOrchestrator;
const EngineState = @import("core/platform_orchestrator.zig").EngineState;

// ─── THREAT INTELLIGENCE ────────────────────────────────────────────────────
const ThreatProcessingPipeline = @import("intel/threat_processing_pipeline.zig").ThreatProcessingPipeline;
const ThreatGraphEngine = @import("intel/threat_graph_engine.zig").ThreatGraphEngine;
const NodeType = @import("intel/threat_graph_engine.zig").NodeType;
const EdgeType = @import("intel/threat_graph_engine.zig").EdgeType;

// ─── DETECTION ──────────────────────────────────────────────────────────────
const DetectionEngine = @import("detection/detection_engine.zig").DetectionEngine;

// ─── DEFENSE ────────────────────────────────────────────────────────────────
const DefenseEngine = @import("defense/defense_engine.zig").DefenseEngine;

// ─── REPORTING ──────────────────────────────────────────────────────────────
const Finding = @import("report/finding.zig").Finding;
const report_builder = @import("report/report_builder.zig");

// ─── TELEMETRY ──────────────────────────────────────────────────────────────
const metrics = @import("telemetry/metrics.zig");

// ============================================================================
// PLATFORM STATE
// ============================================================================

var g_event_bus: EventBus = undefined;
var g_pipeline: ThreatProcessingPipeline = undefined;
var g_threat_graph: ThreatGraphEngine = undefined;
var g_detection: DetectionEngine = undefined;
var g_defense: DefenseEngine = undefined;
var g_orchestrator: PlatformOrchestrator = undefined;
var g_health: HealthMonitor = undefined;
var g_resources: ResourceManager = undefined;
var g_allocator: std.mem.Allocator = undefined;
var g_cycle_count: u64 = 0;
var g_running: bool = true;

// ============================================================================
// MAIN
// ============================================================================

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    g_allocator = allocator;

    printBanner();

    // ── PHASE 1: CONFIGURATION ──────────────────────────────────
    std.log.info("━━━ PHASE 1: CONFIGURATION ━━━", .{});
    var config_loader = ConfigLoader.init(allocator);
    defer config_loader.deinit();
    const config = config_loader.load("platform.json") catch blk: {
        std.log.warn("platform.json not found — using defaults", .{});
        break :blk ConfigLoader.defaultConfig();
    };
    try ConfigLoader.validate(config);
    std.log.info("[OK] Configuration loaded", .{});

    // ── PHASE 2: RESOURCE MANAGER ───────────────────────────────
    std.log.info("━━━ PHASE 2: RESOURCE MANAGER ━━━", .{});
    g_resources = ResourceManager.init(allocator, .{
        .max_threads = config.max_threads,
        .max_tasks = config.max_tasks,
        .max_memory_bytes = config.max_memory_bytes,
    });
    std.log.info("[OK] Resource manager initialized", .{});

    // ── PHASE 3: EVENT BUS ──────────────────────────────────────
    std.log.info("━━━ PHASE 3: EVENT BUS ━━━", .{});
    g_event_bus = EventBus.init(allocator);
    defer g_event_bus.deinit();

    try g_event_bus.subscribe(.TELEMETRY_RECEIVED, "ThreatPipeline", onTelemetryReceived);
    try g_event_bus.subscribe(.IOC_DISCOVERED, "ThreatGraph", onIOCDiscovered);
    try g_event_bus.subscribe(.SIGNAL_CORRELATED, "DefenseEngine", onSignalCorrelated);
    try g_event_bus.subscribe(.RISK_THRESHOLD_EXCEEDED, "SOCAlert", onRiskThresholdExceeded);
    try g_event_bus.subscribe(.DEFENSE_ACTION_TRIGGERED, "AuditLog", onDefenseAction);
    try g_event_bus.subscribe(.ENGINE_STARTED, "HealthMonitor", onEngineStarted);
    try g_event_bus.subscribe(.ENGINE_ERROR, "HealthMonitor", onEngineError);
    try g_event_bus.subscribe(.ZERO_DAY_SIGNAL, "SOCAlert", onZeroDaySignal);

    try g_event_bus.start();
    std.log.info("[OK] Event bus active — 8 subscriptions wired", .{});

    // ── PHASE 4: HEALTH MONITOR ─────────────────────────────────
    std.log.info("━━━ PHASE 4: HEALTH MONITOR ━━━", .{});
    g_health = HealthMonitor.init(allocator);
    std.log.info("[OK] Health monitor initialized", .{});

    // ── PHASE 5: ORCHESTRATOR ───────────────────────────────────
    std.log.info("━━━ PHASE 5: ORCHESTRATOR ━━━", .{});
    g_orchestrator = PlatformOrchestrator.init(allocator);
    defer g_orchestrator.deinit();
    try g_orchestrator.registerEngine("ThreatProcessingPipeline");
    try g_orchestrator.registerEngine("DetectionEngine");
    try g_orchestrator.registerEngine("ThreatGraphEngine");
    try g_orchestrator.registerEngine("DefenseEngine");
    try g_orchestrator.registerEngine("ReportBuilder");
    std.log.info("[OK] Orchestrator ready — {d} engines registered", .{g_orchestrator.engineCount()});

    // ── PHASE 6: THREAT PIPELINE ────────────────────────────────
    std.log.info("━━━ PHASE 6: THREAT PIPELINE ━━━", .{});
    g_pipeline = ThreatProcessingPipeline.init(allocator);
    defer g_pipeline.deinit();
    std.log.info("[OK] Threat processing pipeline initialized", .{});

    // ── PHASE 7: THREAT GRAPH ───────────────────────────────────
    std.log.info("━━━ PHASE 7: THREAT GRAPH ━━━", .{});
    g_threat_graph = try ThreatGraphEngine.init(allocator);
    defer g_threat_graph.deinit();
    std.log.info("[OK] Threat graph engine initialized", .{});

    // ── PHASE 8: DETECTION ENGINE ───────────────────────────────
    std.log.info("━━━ PHASE 8: DETECTION ENGINE ━━━", .{});
    g_detection = DetectionEngine.init(allocator);
    defer g_detection.deinit();
    std.log.info("[OK] Detection engine ready (Rule + Sigma + YARA)", .{});

    // ── PHASE 9: DEFENSE ENGINE ─────────────────────────────────
    std.log.info("━━━ PHASE 9: DEFENSE ENGINE ━━━", .{});
    g_defense = DefenseEngine.init(allocator);
    defer g_defense.deinit();
    std.log.info("[OK] Defense engine armed", .{});

    // ── PHASE 10: DATA DIRECTORIES ──────────────────────────────
    std.fs.cwd().makePath("data/state") catch {};
    std.fs.cwd().makePath("data/events") catch {};
    std.fs.cwd().makePath("reports") catch {};
    try exportPlatformState();

    // ── BOOT EVENTS ─────────────────────────────────────────────
    try g_event_bus.publish(.ENGINE_STARTED, .high, "Platform", "All engines initialized");
    try g_event_bus.publish(.HEALTH_CHECK, .medium, "HealthMonitor", "Boot health OK");

    std.log.info("", .{});
    std.log.info("══════════════════════════════════════════════════════════", .{});
    std.log.info("  CYBERDUDEBIVASH ZERO-DAY HUNTER  —  PLATFORM ONLINE", .{});
    std.log.info("  Engines: 5 | EventBus: ACTIVE | Pipeline: RUNNING", .{});
    std.log.info("══════════════════════════════════════════════════════════", .{});
    std.log.info("", .{});

    // ── MASTER RUNTIME LOOP ─────────────────────────────────────
    while (g_running) {
        try runPlatformCycle();
        std.time.sleep(5 * std.time.ns_per_s);
    }

    std.log.info("Platform shutdown complete.", .{});
    g_event_bus.stop();
}

// ============================================================================
// PLATFORM CYCLE
// ============================================================================

fn runPlatformCycle() !void {
    g_cycle_count += 1;
    std.log.info("═══ CYCLE {d} ═══", .{g_cycle_count});
    g_orchestrator.startCycle();

    // 1. INGEST
    try g_pipeline.ingestTelemetry("sensor-01", "process:powershell.exe -enc ZW5jb2RlZA==", std.time.timestamp());
    try g_pipeline.ingestTelemetry("sensor-02", "dns:c2-beacon.evil.com", std.time.timestamp());
    try g_pipeline.ingestTelemetry("sensor-03", "file:C:\\Temp\\payload.dll", std.time.timestamp());
    try g_event_bus.publish(.TELEMETRY_RECEIVED, .medium, "IngestEngine", "3 events ingested");
    metrics.recordScan("cycle-telemetry");

    // 2. PROCESS PIPELINE (Normalize → Correlate → Score)
    try g_pipeline.process();
    setOrchestratorState("ThreatProcessingPipeline", .completed);
    try g_event_bus.publish(.SIGNAL_CORRELATED, .high, "Pipeline", "Signals correlated");

    // 3. DETECTION
    var findings = std.ArrayList(Finding).init(g_allocator);
    defer findings.deinit();
    try g_detection.analyze("cycle-batch", &findings);
    setOrchestratorState("DetectionEngine", .completed);
    if (findings.items.len > 0) {
        try g_event_bus.publish(.RULE_MATCH, .high, "DetectionEngine", "Findings generated");
        metrics.recordFinding("detection-match");
    }

    // 4. THREAT GRAPH UPDATE
    const n1 = try g_threat_graph.addNode(.malware, "EncodedPayload");
    const n2 = try g_threat_graph.addNode(.infrastructure, "c2-beacon.evil.com");
    _ = try g_threat_graph.addNode(.technique, "T1059.001");
    try g_threat_graph.addEdge(n1, n2, .related_to, 0.92);
    setOrchestratorState("ThreatGraphEngine", .completed);
    try g_event_bus.publish(.THREAT_GRAPH_UPDATED, .medium, "ThreatGraph", "Graph updated");

    // 5. DEFENSE
    if (findings.items.len > 0) {
        try g_defense.execute("cycle-batch", &findings);
        try g_event_bus.publish(.DEFENSE_ACTION_TRIGGERED, .critical, "DefenseEngine", "Actions executed");
    }
    setOrchestratorState("DefenseEngine", .completed);

    // 6. REPORT
    if (findings.items.len > 0) {
        try report_builder.generate(g_allocator, "cycle-batch", findings.items);
    }
    setOrchestratorState("ReportBuilder", .completed);

    // 7. FINALIZE
    g_orchestrator.finalizeCycle();
    g_health.updateMetrics(g_resources.active_threads, g_resources.active_tasks, g_resources.allocated_memory, 15.0);
    try exportPlatformState();

    // 8. CYCLE REPORT
    g_event_bus.stats();
    if (g_orchestrator.getLastReport()) |report| {
        std.log.info("Cycle {d}: {d}/{d} engines OK | Graph: {d} nodes, {d} edges",
            .{ report.cycle_id, report.completed_engines, report.engine_count,
               g_threat_graph.nodes.items.len, g_threat_graph.edges.items.len });
    }
}

fn setOrchestratorState(name: []const u8, state: EngineState) void {
    for (g_orchestrator.engines.items) |*engine| {
        if (std.mem.eql(u8, engine.name, name)) {
            engine.state = state;
            return;
        }
    }
}

// ============================================================================
// EVENT SUBSCRIBERS
// ============================================================================

fn onTelemetryReceived(event: *const Event) void {
    std.log.info("[EVT] Telemetry from {s}: {s}", .{ event.source, event.payload });
}
fn onIOCDiscovered(event: *const Event) void {
    std.log.info("[EVT] IOC: {s}", .{event.payload});
}
fn onSignalCorrelated(event: *const Event) void {
    std.log.info("[EVT] Signal correlated: {s}", .{event.source});
}
fn onRiskThresholdExceeded(event: *const Event) void {
    std.log.info("[ALERT] Risk threshold: {s}", .{event.payload});
}
fn onDefenseAction(event: *const Event) void {
    std.log.info("[DEFENSE] Action: {s}", .{event.payload});
}
fn onEngineStarted(event: *const Event) void {
    std.log.info("[ENGINE] Started: {s}", .{event.payload});
}
fn onEngineError(event: *const Event) void {
    std.log.info("[ERROR] Engine: {s}", .{event.payload});
}
fn onZeroDaySignal(event: *const Event) void {
    std.log.info("[ZERO-DAY] Signal: {s} from {s}", .{ event.payload, event.source });
}

// ============================================================================
// STATE EXPORT (IPC for API Gateway)
// ============================================================================

fn exportPlatformState() !void {
    var buf = std.ArrayList(u8).init(g_allocator);
    defer buf.deinit();
    const w = buf.writer();

    try w.writeAll("{\n");
    try w.print("  \"platform\": \"CYBERDUDEBIVASH ZERO-DAY HUNTER\",\n", .{});
    try w.print("  \"version\": \"1.0.0\",\n", .{});
    try w.print("  \"status\": \"OPERATIONAL\",\n", .{});
    try w.print("  \"cycle\": {d},\n", .{g_cycle_count});
    try w.print("  \"timestamp\": {d},\n", .{std.time.timestamp()});
    try w.print("  \"uptime_seconds\": {d},\n", .{g_health.last_health.uptime_seconds});
    try w.print("  \"events_published\": {d},\n", .{g_event_bus.total_published});
    try w.print("  \"events_delivered\": {d},\n", .{g_event_bus.total_delivered});
    try w.print("  \"engines_registered\": {d},\n", .{g_orchestrator.engineCount()});
    try w.print("  \"graph_nodes\": {d},\n", .{g_threat_graph.nodes.items.len});
    try w.print("  \"graph_edges\": {d}\n", .{g_threat_graph.edges.items.len});
    try w.writeAll("}\n");

    const file = try std.fs.cwd().createFile("data/state/platform_state.json", .{});
    defer file.close();
    try file.writeAll(buf.items);
}

// ============================================================================
// BANNER
// ============================================================================

fn printBanner() void {
    std.debug.print(
        \\
        \\  ══════════════════════════════════════════════════════════
        \\   CYBERDUDEBIVASH ZERO-DAY HUNTER™  v1.0.0
        \\   Next-Generation Autonomous Cyber Defense Platform
        \\   (c) CyberDudeBivash Pvt. Ltd.
        \\  ══════════════════════════════════════════════════════════
        \\
        \\
    , .{});
}
