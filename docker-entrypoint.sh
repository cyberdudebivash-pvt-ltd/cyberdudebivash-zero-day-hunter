#!/bin/bash
# CYBERDUDEBIVASH ZERO-DAY HUNTER™ — Docker Entrypoint
# Starts Zig runtime + Python API gateway

set -e

echo "════════════════════════════════════════════════"
echo " CYBERDUDEBIVASH ZERO-DAY HUNTER™"
echo " Starting Platform Runtime + API Gateway"
echo "════════════════════════════════════════════════"

# Start Zig runtime in background
echo "[*] Starting Zig runtime..."
cd /app && ./zdh-runtime &
ZIG_PID=$!

# Wait for state file
echo "[*] Waiting for runtime initialization..."
for i in $(seq 1 30); do
    if [ -f /app/data/state/platform_state.json ]; then
        echo "[OK] Runtime state available"
        break
    fi
    sleep 1
done

# Start API gateway
echo "[*] Starting API gateway on port ${GATEWAY_PORT:-9000}..."
cd /app/gateway && python -m uvicorn api:app \
    --host 0.0.0.0 \
    --port ${GATEWAY_PORT:-9000} \
    --workers ${GATEWAY_WORKERS:-2} \
    --log-level info &
GW_PID=$!

echo "[OK] Platform fully operational"
echo "  Runtime PID: $ZIG_PID"
echo "  Gateway PID: $GW_PID"
echo "  API: http://localhost:${GATEWAY_PORT:-9000}/api/health"
echo "  WebSocket: ws://localhost:${GATEWAY_PORT:-9000}/ws/stream"

# Wait for either process
wait -n $ZIG_PID $GW_PID
EXIT_CODE=$?

echo "[!] Process exited with code $EXIT_CODE — shutting down..."
kill $ZIG_PID $GW_PID 2>/dev/null || true
exit $EXIT_CODE
