"use strict";

/*
CYBERDUDEBIVASH ZERO-DAY HUNTER™

Cyber Cluster Orchestrator

Enterprise Distributed SOC Control Plane

Responsibilities
----------------
• cluster lifecycle management
• node registration
• workload distribution
• failover handling
• SOC module orchestration
• integration with NodeSync + EventBus
*/

const EventEmitter = require("events");

class CyberClusterOrchestrator extends EventEmitter {

    constructor(options = {}) {

        super();

        this.nodeSync = null;
        this.eventBus = null;

        this.clusterNodes = new Map();

        this.workloadQueue = [];

        this.maxConcurrentTasks = options.maxConcurrentTasks || 20;

        this.activeTasks = new Map();

        this.taskIdCounter = 0;

        this.running = false;

        this.telemetryAdapter = null;

        this.stats = {
            nodesRegistered: 0,
            nodesRemoved: 0,
            tasksScheduled: 0,
            tasksCompleted: 0,
            tasksFailed: 0
        };

    }

    /*
    -------------------------------------------------
    ATTACH ENGINES
    -------------------------------------------------
    */

    attachNodeSyncEngine(nodeSyncEngine) {

        this.nodeSync = nodeSyncEngine;

        nodeSyncEngine.on("clusterTask", (task) => {

            this.executeLocalTask(task);

        });

    }

    attachEventBus(eventBus) {

        this.eventBus = eventBus;

    }

    attachTelemetryAdapter(adapter) {

        this.telemetryAdapter = adapter;

    }

    /*
    -------------------------------------------------
    START ORCHESTRATOR
    -------------------------------------------------
    */

    start() {

        if (this.running) return;

        this.running = true;

        this.startNodeDiscovery();

        this.startWorkloadScheduler();

        console.log("[ClusterOrchestrator] Started");

    }

    stop() {

        this.running = false;

        if (this.discoveryTimer) clearInterval(this.discoveryTimer);
        if (this.schedulerTimer) clearInterval(this.schedulerTimer);

    }

    /*
    -------------------------------------------------
    NODE DISCOVERY
    -------------------------------------------------
    */

    startNodeDiscovery() {

        this.discoveryTimer = setInterval(() => {

            if (!this.nodeSync) return;

            const nodes = this.nodeSync.getClusterNodes();

            const knownIds = new Set();

            for (const node of nodes) {

                knownIds.add(node.nodeId);

                if (!this.clusterNodes.has(node.nodeId)) {

                    this.clusterNodes.set(node.nodeId, {
                        ...node,
                        workloads: 0
                    });

                    this.stats.nodesRegistered++;

                    console.log("[ClusterOrchestrator] Node registered:", node.nodeId);

                }

            }

            for (const [nodeId] of this.clusterNodes.entries()) {

                if (!knownIds.has(nodeId)) {

                    this.clusterNodes.delete(nodeId);

                    this.stats.nodesRemoved++;

                    console.warn("[ClusterOrchestrator] Node removed:", nodeId);

                }

            }

        }, 4000);

    }

    /*
    -------------------------------------------------
    WORKLOAD MANAGEMENT
    -------------------------------------------------
    */

    submitTask(task) {

        const taskId = "task-" + (++this.taskIdCounter);

        const workload = {
            id: taskId,
            task,
            created: Date.now()
        };

        this.workloadQueue.push(workload);

        this.stats.tasksScheduled++;

        return taskId;

    }

    startWorkloadScheduler() {

        this.schedulerTimer = setInterval(() => {

            if (!this.running) return;

            if (this.workloadQueue.length === 0) return;

            if (this.activeTasks.size >= this.maxConcurrentTasks) return;

            const workload = this.workloadQueue.shift();

            const node = this.selectNode();

            if (!node) {

                this.workloadQueue.unshift(workload);

                return;

            }

            this.dispatchTaskToNode(node.nodeId, workload);

        }, 200);

    }

    /*
    -------------------------------------------------
    NODE SELECTION
    -------------------------------------------------
    */

    selectNode() {

        let selected = null;

        for (const node of this.clusterNodes.values()) {

            if (!selected || node.workloads < selected.workloads) {

                selected = node;

            }

        }

        return selected;

    }

    /*
    -------------------------------------------------
    TASK DISPATCH
    -------------------------------------------------
    */

    dispatchTaskToNode(nodeId, workload) {

        const message = {

            taskId: workload.id,
            payload: workload.task

        };

        if (this.nodeSync) {

            this.nodeSync.dispatchTask(message);

        }

        this.activeTasks.set(workload.id, {

            nodeId,
            startTime: Date.now()

        });

        const node = this.clusterNodes.get(nodeId);

        if (node) node.workloads++;

        this.recordTelemetry("task_dispatched", { nodeId });

    }

    /*
    -------------------------------------------------
    LOCAL TASK EXECUTION
    -------------------------------------------------
    */

    executeLocalTask(taskMessage) {

        const { taskId, payload } = taskMessage;

        try {

            this.emit("executeTask", payload);

            this.completeTask(taskId);

        } catch (err) {

            this.failTask(taskId);

        }

    }

    /*
    -------------------------------------------------
    TASK COMPLETION
    -------------------------------------------------
    */

    completeTask(taskId) {

        const task = this.activeTasks.get(taskId);

        if (!task) return;

        const node = this.clusterNodes.get(task.nodeId);

        if (node) node.workloads--;

        this.activeTasks.delete(taskId);

        this.stats.tasksCompleted++;

        this.recordTelemetry("task_completed", { taskId });

    }

    failTask(taskId) {

        const task = this.activeTasks.get(taskId);

        if (!task) return;

        const node = this.clusterNodes.get(task.nodeId);

        if (node) node.workloads--;

        this.activeTasks.delete(taskId);

        this.stats.tasksFailed++;

        this.recordTelemetry("task_failed", { taskId });

    }

    /*
    -------------------------------------------------
    FAILOVER MONITOR
    -------------------------------------------------
    */

    checkForStalledTasks(timeout = 30000) {

        const now = Date.now();

        for (const [taskId, task] of this.activeTasks.entries()) {

            if (now - task.startTime > timeout) {

                console.warn("[ClusterOrchestrator] Task timeout:", taskId);

                this.failTask(taskId);

            }

        }

    }

    /*
    -------------------------------------------------
    CLUSTER STATUS
    -------------------------------------------------
    */

    getClusterStatus() {

        return {

            nodes: Array.from(this.clusterNodes.values()),
            activeTasks: this.activeTasks.size,
            queuedTasks: this.workloadQueue.length,
            ...this.stats

        };

    }

    /*
    -------------------------------------------------
    TELEMETRY
    -------------------------------------------------
    */

    recordTelemetry(event, data = {}) {

        if (!this.telemetryAdapter) return;

        try {

            this.telemetryAdapter.record({

                component: "CyberClusterOrchestrator",
                event,
                timestamp: Date.now(),
                ...data

            });

        } catch (err) {

            console.error("Telemetry error:", err);

        }

    }

}

module.exports = CyberClusterOrchestrator;