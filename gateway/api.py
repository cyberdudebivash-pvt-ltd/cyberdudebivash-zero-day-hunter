"""
CYBERDUDEBIVASH ZERO-DAY HUNTER™ — API Gateway
Production-grade REST + WebSocket API Gateway

Reads platform state from Zig runtime via shared JSON (IPC).
Exposes unified API endpoints for SOC dashboard, integrations, and monitoring.

(c) CyberDudeBivash Pvt. Ltd.
"""

import json
import os
import time
import asyncio
import hashlib
import secrets
from pathlib import Path
from datetime import datetime, timezone
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect, Depends, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STATE_FILE = os.getenv("STATE_FILE", "../data/state/platform_state.json")
REPORT_DIR = os.getenv("REPORT_DIR", "../reports")
API_KEY = os.getenv("ZDH_API_KEY", "cyberdudebivash-dev-key-change-in-production")
GATEWAY_PORT = int(os.getenv("GATEWAY_PORT", "9000"))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STATE READER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def read_platform_state() -> dict:
    """Read platform state exported by Zig runtime."""
    try:
        path = Path(STATE_FILE)
        if path.exists():
            with open(path) as f:
                return json.load(f)
    except (json.JSONDecodeError, IOError):
        pass
    return {
        "platform": "CYBERDUDEBIVASH ZERO-DAY HUNTER",
        "status": "STARTING",
        "cycle": 0,
        "timestamp": int(time.time()),
    }


def read_reports() -> list:
    """Read generated threat reports."""
    reports = []
    report_dir = Path(REPORT_DIR)
    if report_dir.exists():
        for f in sorted(report_dir.glob("*.json"), reverse=True)[:50]:
            try:
                with open(f) as fh:
                    reports.append(json.load(fh))
            except (json.JSONDecodeError, IOError):
                continue
    return reports


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# AUTH
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def verify_api_key(x_api_key: Optional[str] = Header(None)):
    """Simple API key authentication."""
    if x_api_key is None or not secrets.compare_digest(x_api_key, API_KEY):
        raise HTTPException(status_code=401, detail="Invalid or missing API key")
    return x_api_key


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WEBSOCKET MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ConnectionManager:
    def __init__(self):
        self.active: list[WebSocket] = []

    async def connect(self, ws: WebSocket):
        await ws.accept()
        self.active.append(ws)

    def disconnect(self, ws: WebSocket):
        if ws in self.active:
            self.active.remove(ws)

    async def broadcast(self, data: dict):
        dead = []
        for ws in self.active:
            try:
                await ws.send_json(data)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(ws)


ws_manager = ConnectionManager()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BACKGROUND TASK — State broadcast
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def state_broadcaster():
    """Broadcast platform state to WebSocket clients every 3 seconds."""
    while True:
        state = read_platform_state()
        state["_broadcast_time"] = datetime.now(timezone.utc).isoformat()
        await ws_manager.broadcast(state)
        await asyncio.sleep(3)


@asynccontextmanager
async def lifespan(app: FastAPI):
    task = asyncio.create_task(state_broadcaster())
    yield
    task.cancel()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

app = FastAPI(
    title="CYBERDUDEBIVASH ZERO-DAY HUNTER™ API",
    description="Unified API Gateway for the Zero-Day Hunter Platform",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PUBLIC ENDPOINTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.get("/api/health")
async def health():
    state = read_platform_state()
    return {
        "status": "healthy",
        "platform": state.get("platform", "UNKNOWN"),
        "runtime_status": state.get("status", "UNKNOWN"),
        "cycle": state.get("cycle", 0),
        "uptime": state.get("uptime_seconds", 0),
        "gateway_time": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/api/status")
async def platform_status(key: str = Depends(verify_api_key)):
    return read_platform_state()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# THREAT INTELLIGENCE ENDPOINTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.get("/api/threats")
async def get_threats(key: str = Depends(verify_api_key)):
    state = read_platform_state()
    reports = read_reports()
    findings = []
    for r in reports:
        for f in r.get("findings", []):
            findings.append(f)
    return {
        "total_findings": len(findings),
        "graph_nodes": state.get("graph_nodes", 0),
        "graph_edges": state.get("graph_edges", 0),
        "findings": findings[:100],
    }


@app.get("/api/threats/graph")
async def get_threat_graph(key: str = Depends(verify_api_key)):
    state = read_platform_state()
    return {
        "nodes": state.get("graph_nodes", 0),
        "edges": state.get("graph_edges", 0),
        "engine": "ThreatGraphEngine",
        "status": "active",
    }


@app.get("/api/events")
async def get_events(key: str = Depends(verify_api_key)):
    state = read_platform_state()
    return {
        "total_published": state.get("events_published", 0),
        "total_delivered": state.get("events_delivered", 0),
        "event_bus": "active",
    }


@app.get("/api/reports")
async def get_reports(
    limit: int = Query(default=20, le=100),
    key: str = Depends(verify_api_key),
):
    reports = read_reports()
    return {"total": len(reports), "reports": reports[:limit]}


@app.get("/api/defense-actions")
async def get_defense_actions(key: str = Depends(verify_api_key)):
    reports = read_reports()
    actions = []
    for r in reports:
        for f in r.get("findings", []):
            actions.append({
                "finding": f.get("type", "unknown"),
                "severity": f.get("severity", "info"),
                "hunter": f.get("hunter", "unknown"),
                "target": r.get("target", "unknown"),
            })
    return {"total_actions": len(actions), "actions": actions[:50]}


@app.get("/api/engines")
async def get_engines(key: str = Depends(verify_api_key)):
    state = read_platform_state()
    return {
        "registered": state.get("engines_registered", 0),
        "engines": [
            {"name": "ThreatProcessingPipeline", "status": "active"},
            {"name": "DetectionEngine", "status": "active"},
            {"name": "ThreatGraphEngine", "status": "active"},
            {"name": "DefenseEngine", "status": "active"},
            {"name": "ReportBuilder", "status": "active"},
        ],
    }


@app.get("/api/metrics")
async def get_metrics(key: str = Depends(verify_api_key)):
    state = read_platform_state()
    return {
        "cycle_count": state.get("cycle", 0),
        "uptime_seconds": state.get("uptime_seconds", 0),
        "events_published": state.get("events_published", 0),
        "events_delivered": state.get("events_delivered", 0),
        "graph_nodes": state.get("graph_nodes", 0),
        "graph_edges": state.get("graph_edges", 0),
        "engines_registered": state.get("engines_registered", 0),
        "gateway_connections": len(ws_manager.active),
    }


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WEBSOCKET — REAL-TIME SOC STREAM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.websocket("/ws/stream")
async def websocket_stream(ws: WebSocket):
    await ws_manager.connect(ws)
    try:
        while True:
            data = await ws.receive_text()
            if data == "ping":
                await ws.send_json({"type": "pong", "time": time.time()})
    except WebSocketDisconnect:
        ws_manager.disconnect(ws)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=GATEWAY_PORT)
