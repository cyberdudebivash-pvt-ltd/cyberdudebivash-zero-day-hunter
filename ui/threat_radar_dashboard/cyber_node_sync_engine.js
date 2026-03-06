"use strict";

/*
CYBERDUDEBIVASH ZERO-DAY HUNTER™

Cyber Node Sync Engine

Purpose
-------
Distributed cluster synchronization
for multi-node SOC infrastructure.

Capabilities
------------
• node discovery
• cluster registry
• heartbeat monitoring
• event replication
• distributed task dispatch
• failover awareness
• telemetry hooks
*/

const crypto = require("crypto");
const EventEmitter = require("events");

class CyberNodeSyncEngine extends EventEmitter {

    constructor(options = {}) {

        super();

        this.nodeId = options.nodeId || this.generateNodeId();
        this.nodeAddress = options.nodeAddress || "localhost";

        this.heartbeatInterval = options.heartbeatInterval || 5000;
        this.nodeTimeout = options.nodeTimeout || 20000;

        this.nodes = new Map();

        this.eventBus = null;

        this.clusterAdapter = null;

        this.telemetryAdapter = null;

        this.running = false;

        this.stats = {
            nodesDiscovered: 0,
            messagesReceived: 0,
            messagesSent: 0,
            heartbeatsSent: 0,
            heartbeatsReceived: 0,
            nodesRemoved: 0
        };

    }

    /*
    ------------------------------------------------
    INITIALIZATION
    ------------------------------------------------
    */

    attachEventBus(eventBus) {

        this.eventBus = eventBus;

    }

    attachClusterAdapter(adapter) {

        this.clusterAdapter = adapter;

        if (adapter && adapter.onMessage) {

            adapter.onMessage((msg, source) => {

                this.handleClusterMessage(msg, source);

            });

        }

    }

    attachTelemetryAdapter(adapter) {

        this.telemetryAdapter = adapter;

    }

    /*
    ------------------------------------------------
    ENGINE START
    ------------------------------------------------
    */

    start() {

        if (this.running) return;

        this.running = true;

        this.startHeartbeat();

        this.startNodeMonitor();

        console.log(`[NodeSync] Node started: ${this.nodeId}`);

    }

    stop() {

        this.running = false;

        if (this.heartbeatTimer) clearInterval(this.heartbeatTimer);
        if (this.monitorTimer) clearInterval(this.monitorTimer);

    }

    /*
    ------------------------------------------------
    HEARTBEAT SYSTEM
    ------------------------------------------------
    */

    startHeartbeat() {

        this.heartbeatTimer = setInterval(() => {

            const heartbeat = {

                type: "NODE_HEARTBEAT",
                nodeId: this.nodeId,
                address: this.nodeAddress,
                timestamp: Date.now()

            };

            this.broadcast(heartbeat);

            this.stats.heartbeatsSent++;

        }, this.heartbeatInterval);

    }

    /*
    ------------------------------------------------
    NODE MONITOR
    ------------------------------------------------
    */

    startNodeMonitor() {

        this.monitorTimer = setInterval(() => {

            const now = Date.now();

            for (const [nodeId, node] of this.nodes.entries()) {

                if (now - node.lastSeen > this.nodeTimeout) {

                    this.nodes.delete(nodeId);

                    this.stats.nodesRemoved++;

                    console.warn(`[NodeSync] Node removed (timeout): ${nodeId}`);

                }

            }

        }, this.heartbeatInterval);

    }

    /*
    ------------------------------------------------
    CLUSTER MESSAGING
    ------------------------------------------------
    */

    handleClusterMessage(msg, source) {

        this.stats.messagesReceived++;

        if (!msg || !msg.type) return;

        switch (msg.type) {

            case "NODE_HEARTBEAT":

                this.registerNode(msg);

                break;

            case "EVENT_REPLICATION":

                this.replicateEvent(msg.event);

                break;

            case "CLUSTER_TASK":

                this.executeClusterTask(msg.task);

                break;

            default:

                console.warn("Unknown cluster message:", msg.type);

        }

    }

    /*
    ------------------------------------------------
    NODE REGISTRY
    ------------------------------------------------
    */

    registerNode(msg) {

        if (msg.nodeId === this.nodeId) return;

        if (!this.nodes.has(msg.nodeId)) {

            this.stats.nodesDiscovered++;

            console.log(`[NodeSync] New node discovered: ${msg.nodeId}`);

        }

        this.nodes.set(msg.nodeId, {

            nodeId: msg.nodeId,
            address: msg.address,
            lastSeen: Date.now()

        });

        this.stats.heartbeatsReceived++;

    }

    /*
    ------------------------------------------------
    EVENT REPLICATION
    ------------------------------------------------
    */

    replicateEvent(event) {

        if (!this.eventBus) return;

        try {

            this.eventBus.emitEvent(
                event.type,
                event.payload,
                {
                    priority: event.priority,
                    source: "CLUSTER_NODE",
                    propagate: false
                }
            );

        } catch (err) {

            console.error("Event replication error:", err);

        }

    }

    broadcastEvent(event) {

        const message = {

            type: "EVENT_REPLICATION",
            event

        };

        this.broadcast(message);

    }

    /*
    ------------------------------------------------
    DISTRIBUTED TASK EXECUTION
    ------------------------------------------------
    */

    executeClusterTask(task) {

        try {

            this.emit("clusterTask", task);

        } catch (err) {

            console.error("Cluster task execution error:", err);

        }

    }

    dispatchTask(task) {

        const message = {

            type: "CLUSTER_TASK",
            task

        };

        this.broadcast(message);

    }

    /*
    ------------------------------------------------
    BROADCAST
    ------------------------------------------------
    */

    broadcast(message) {

        if (!this.clusterAdapter) return;

        try {

            this.clusterAdapter.broadcast(message);

            this.stats.messagesSent++;

        } catch (err) {

            console.error("Cluster broadcast error:", err);

        }

    }

    /*
    ------------------------------------------------
    NODE STATUS
    ------------------------------------------------
    */

    getClusterNodes() {

        return Array.from(this.nodes.values());

    }

    getClusterSize() {

        return this.nodes.size + 1;

    }

    /*
    ------------------------------------------------
    UTILITIES
    ------------------------------------------------
    */

    generateNodeId() {

        return "node-" + crypto.randomBytes(6).toString("hex");

    }

    /*
    ------------------------------------------------
    TELEMETRY
    ------------------------------------------------
    */

    recordTelemetry(event, data = {}) {

        if (!this.telemetryAdapter) return;

        try {

            this.telemetryAdapter.record({

                component: "CyberNodeSyncEngine",
                event,
                nodeId: this.nodeId,
                timestamp: Date.now(),
                ...data

            });

        } catch (err) {

            console.error("Telemetry error:", err);

        }

    }

    /*
    ------------------------------------------------
    HEALTH METRICS
    ------------------------------------------------
    */

    getStats() {

        return {

            nodeId: this.nodeId,
            nodesKnown: this.nodes.size,
            ...this.stats

        };

    }

}

module.exports = CyberNodeSyncEngine;