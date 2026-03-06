#!/usr/bin/env bash
# CYBERDUDEBIVASH ZERO-DAY HUNTER™ — Production Build Script v1.0
# Run from project ROOT folder

set -euo pipefail

echo "================================================================"
echo " CYBERDUDEBIVASH ZERO-DAY HUNTER™ — Enterprise Build v1.0"
echo "================================================================"

# 1. Verify we are in project root
if [[ ! -f "build.zig" || ! -d "src" ]]; then
    echo "ERROR: Please run this script from the project ROOT folder"
    echo "       (where build.zig, src/, scripts/ etc. exist)"
    exit 1
fi

# 2. Clean old artifacts
echo "Cleaning old build artifacts..."
rm -rf zig-out zig-cache 2>/dev/null || true

# 3. Verify zig is available
if ! command -v zig >/dev/null 2>&1; then
    echo "ERROR: zig not found in PATH"
    echo "       Make sure you ran: export PATH=\"\$PWD/zig:\$PATH\""
    echo "       or installed Zig correctly"
    exit 1
fi

echo "Zig version: $(zig version)"

# 4. Build the main executable (ReleaseSmall + stripped)
echo "Building main binary (ReleaseSmall + stripped)..."
zig build -Doptimize=ReleaseSmall --release=small

# 5. Verify binary exists
BINARY="zig-out/bin/cyberdudebivash-zero-day-hunter"
if [[ -f "$BINARY" ]]; then
    echo "Build SUCCESS!"
    echo "Binary created: $BINARY"
    ls -lh "$BINARY"
else
    echo "ERROR: Binary not found at $BINARY"
    echo "Build may have failed silently — check zig build output above"
    exit 1
fi

# 6. Optional: Try to build Windows .exe if cross-compilation is set up
echo "Checking for Windows cross-compilation..."
if zig build-exe -O ReleaseSmall -target x86_64-windows src/main.zig -femit-bin=bin/cyberdudebivash-zero-day-hunter.exe 2>/dev/null; then
    echo "Windows .exe created: bin/cyberdudebivash-zero-day-hunter.exe"
else
    echo "Windows cross-build skipped (normal if not configured)"
fi

# 7. Final success message
echo ""
echo "================================================================"
echo " BUILD COMPLETE — READY FOR DEPLOYMENT"
echo " Binary: $BINARY"
echo " Size:   $(du -h "$BINARY" | cut -f1)"
echo " Ready for Gumroad, Threat Intel integration, and enterprise sale"
echo "================================================================"
echo ""
echo "Next steps:"
echo "  ./$BINARY           → Run the hunter"
echo "  DM 'ZERODAYHUNT'    → Get enterprise licensing & docs"
echo ""