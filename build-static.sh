#!/usr/bin/env bash
# Portable fully-static musl ffmpeg (requires Docker). Output: .dist/musl-x86_64/bin/
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
DIST="$SCRIPT_DIR/.dist/musl-x86_64"
STATIC="$SCRIPT_DIR/static"
IMAGE="${ALPINE_IMAGE:-alpine:3.21}"

command -v docker >/dev/null || { echo "docker required"; exit 1; }

mkdir -p "$DIST"
chmod +x "$SCRIPT_DIR/scripts/musl-build-inner.sh"

echo "Building static musl ffmpeg in $IMAGE → $DIST"
docker run --rm \
    -v "$SCRIPT_DIR:/src:ro" \
    -v "$DIST:/dist" \
    -e SRC=/src \
    -e PREFIX=/dist \
    -e JOBS="$(nproc)" \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    "$IMAGE" \
    /src/scripts/musl-build-inner.sh

chown -R "$(id -u):$(id -g)" "$DIST" 2>/dev/null || \
    echo "Note: run sudo chown -R $(id -u):$(id -g) $DIST"

echo
ls -lh "$DIST/bin/ffmpeg" "$DIST/bin/ffprobe"
file "$DIST/bin/ffmpeg"
ldd "$DIST/bin/ffmpeg" 2>&1 || true

cp "$DIST/bin/ffmpeg" "$STATIC"
cp "$DIST/bin/ffprobe" "$STATIC"