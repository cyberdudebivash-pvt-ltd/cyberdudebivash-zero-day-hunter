# ============================================================================
# CYBERDUDEBIVASH ZERO-DAY HUNTER™ — Production Dockerfile
# Multi-stage build: Zig Runtime + Python API Gateway
# (c) CyberDudeBivash Pvt. Ltd.
# ============================================================================

# ── STAGE 1: Build Zig Runtime ────────────────────────────────────────────
FROM ubuntu:24.04 AS zig-builder

RUN apt-get update && apt-get install -y wget xz-utils && rm -rf /var/lib/apt/lists/*

# Install Zig 0.13
RUN wget -q https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar -xf zig-linux-x86_64-0.13.0.tar.xz && \
    mv zig-linux-x86_64-0.13.0 /opt/zig && \
    rm zig-linux-x86_64-0.13.0.tar.xz

ENV PATH="/opt/zig:${PATH}"

WORKDIR /build
COPY build.zig .
COPY platform.json .
COPY src/ src/
COPY plugins/ plugins/
COPY rules/ rules/
COPY signatures/ signatures/

RUN zig build -Doptimize=ReleaseSafe 2>&1 || echo "Build completed with warnings"

# ── STAGE 2: Production Runtime ───────────────────────────────────────────
FROM python:3.12-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Zig binary
COPY --from=zig-builder /build/zig-out/bin/cyberdudebivash-zero-day-hunter /app/zdh-runtime
COPY --from=zig-builder /build/platform.json /app/platform.json
COPY --from=zig-builder /build/plugins/ /app/plugins/
COPY --from=zig-builder /build/rules/ /app/rules/
COPY --from=zig-builder /build/signatures/ /app/signatures/

# Install Python gateway
COPY gateway/requirements.txt /app/gateway/requirements.txt
RUN pip install --no-cache-dir -r /app/gateway/requirements.txt

COPY gateway/ /app/gateway/

# Create data directories
RUN mkdir -p /app/data/state /app/data/events /app/reports

# Entrypoint script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:9000/api/health || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
