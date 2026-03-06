"use strict";

/*
CYBERDUDEBIVASH ZERO-DAY HUNTER™
Cyber Event Bus

Enterprise Threat Platform Communication Layer

Capabilities
-------------
• Async event routing
• Priority queues
• Subscriber registry
• Runtime-safe dispatch
• Cluster propagation hooks
• Telemetry integration
• Event replay buffer
• High-throughput architecture
*/

const { EventEmitter } = require("events");

class CyberEventBus extends EventEmitter {

    constructor(options = {}) {
        super();

        this.maxListeners = options.maxListeners || 500;
        this.setMaxListeners(this.maxListeners);

        this.subscribers = new Map();
        this.priorityQueues = {
            CRITICAL: [],
            HIGH: [],
            NORMAL: [],
            LOW: []
        };

        this.eventHistory = [];
        this.maxHistory = options.maxHistory || 5000;

        this.clusterAdapter = null;
        this.telemetryAdapter = null;

        this.processing = false;

        this.stats = {
            eventsReceived: 0,
            eventsDispatched: 0,
            subscriberExecutions: 0,
            failures: 0
        };
    }

    /*
    -------------------------------------------------
    EVENT SUBSCRIPTION
    -------------------------------------------------
    */

    subscribe(eventType, handler) {

        if (!this.subscribers.has(eventType)) {
            this.subscribers.set(eventType, new Set());
        }

        this.subscribers.get(eventType).add(handler);

        return () => {
            this.unsubscribe(eventType, handler);
        };
    }

    unsubscribe(eventType, handler) {

        if (!this.subscribers.has(eventType)) {
            return;
        }

        this.subscribers.get(eventType).delete(handler);

        if (this.subscribers.get(eventType).size === 0) {
            this.subscribers.delete(eventType);
        }
    }

    /*
    -------------------------------------------------
    EVENT EMISSION
    -------------------------------------------------
    */

    emitEvent(eventType, payload = {}, options = {}) {

        const event = {
            id: this.generateEventId(),
            type: eventType,
            payload,
            timestamp: Date.now(),
            priority: options.priority || "NORMAL",
            source: options.source || "UNKNOWN",
            propagate: options.propagate !== false
        };

        this.stats.eventsReceived++;

        this.enqueueEvent(event);

        if (event.propagate && this.clusterAdapter) {
            this.clusterAdapter.broadcast(event);
        }

        this.recordEvent(event);

        this.processQueue();
    }

    /*
    -------------------------------------------------
    PRIORITY QUEUE
    -------------------------------------------------
    */

    enqueueEvent(event) {

        const priority = event.priority.toUpperCase();

        if (!this.priorityQueues[priority]) {
            this.priorityQueues.NORMAL.push(event);
            return;
        }

        this.priorityQueues[priority].push(event);
    }

    getNextEvent() {

        if (this.priorityQueues.CRITICAL.length) return this.priorityQueues.CRITICAL.shift();
        if (this.priorityQueues.HIGH.length) return this.priorityQueues.HIGH.shift();
        if (this.priorityQueues.NORMAL.length) return this.priorityQueues.NORMAL.shift();
        if (this.priorityQueues.LOW.length) return this.priorityQueues.LOW.shift();

        return null;
    }

    /*
    -------------------------------------------------
    QUEUE PROCESSING
    -------------------------------------------------
    */

    async processQueue() {

        if (this.processing) return;

        this.processing = true;

        try {

            let event;

            while ((event = this.getNextEvent())) {

                await this.dispatchEvent(event);

            }

        } catch (err) {

            this.stats.failures++;

            console.error("CyberEventBus Processing Error:", err);

        } finally {

            this.processing = false;

        }
    }

    /*
    -------------------------------------------------
    EVENT DISPATCH
    -------------------------------------------------
    */

    async dispatchEvent(event) {

        const handlers = this.subscribers.get(event.type);

        if (!handlers || handlers.size === 0) {
            return;
        }

        for (const handler of handlers) {

            try {

                await handler(event);

                this.stats.subscriberExecutions++;

            } catch (err) {

                this.stats.failures++;

                console.error(
                    "CyberEventBus Handler Failure:",
                    event.type,
                    err
                );

            }
        }

        this.stats.eventsDispatched++;

        this.telemetry(event);
    }

    /*
    -------------------------------------------------
    EVENT HISTORY
    -------------------------------------------------
    */

    recordEvent(event) {

        this.eventHistory.push(event);

        if (this.eventHistory.length > this.maxHistory) {
            this.eventHistory.shift();
        }
    }

    replayEvents(eventType, handler) {

        for (const event of this.eventHistory) {

            if (event.type === eventType) {

                handler(event);

            }

        }
    }

    /*
    -------------------------------------------------
    TELEMETRY
    -------------------------------------------------
    */

    telemetry(event) {

        if (!this.telemetryAdapter) return;

        try {

            this.telemetryAdapter.record({
                type: event.type,
                source: event.source,
                priority: event.priority,
                timestamp: event.timestamp
            });

        } catch (err) {

            console.error("Telemetry Adapter Failure:", err);

        }
    }

    /*
    -------------------------------------------------
    CLUSTER INTEGRATION
    -------------------------------------------------
    */

    attachClusterAdapter(adapter) {

        this.clusterAdapter = adapter;

        if (adapter && adapter.onEvent) {

            adapter.onEvent((event) => {

                this.enqueueEvent(event);
                this.processQueue();

            });

        }
    }

    /*
    -------------------------------------------------
    TELEMETRY INTEGRATION
    -------------------------------------------------
    */

    attachTelemetryAdapter(adapter) {

        this.telemetryAdapter = adapter;

    }

    /*
    -------------------------------------------------
    UTILITIES
    -------------------------------------------------
    */

    generateEventId() {

        return (
            "evt-" +
            Date.now().toString(36) +
            "-" +
            Math.random().toString(36).substring(2, 8)
        );

    }

    /*
    -------------------------------------------------
    HEALTH STATUS
    -------------------------------------------------
    */

    getStats() {

        return {
            ...this.stats,
            queueDepth: {
                CRITICAL: this.priorityQueues.CRITICAL.length,
                HIGH: this.priorityQueues.HIGH.length,
                NORMAL: this.priorityQueues.NORMAL.length,
                LOW: this.priorityQueues.LOW.length
            },
            subscribers: this.subscribers.size
        };

    }

}

module.exports = CyberEventBus;