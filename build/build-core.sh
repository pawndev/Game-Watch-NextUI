#!/usr/bin/env bash
# Cross-compile gw_libretro.so for the TrimUI Brick / Smart Pro (tg5040, aarch64)
#
# IMPORTANT: run inside a tg5040 toolchain (Docker, see build/Dockerfile
# or shauninman/union-tg5040-toolchain). A recent Ubuntu gcc-aarch64 produces
# a .so incompatible with the firmware glibc (crash on launch).
#
# Usage:
#   ./build/build-core.sh
# The core is copied to Emus/tg5040/GW.pak/gw_libretro.so

set -euo pipefail

REPO_URL="https://github.com/libretro/gw-libretro.git"
WORK_DIR="$(mktemp -d)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEST="$PROJECT_ROOT/Emus/tg5040/GW.pak/gw_libretro.so"

# --- Toolchain detection ---
# 1) CROSS_COMPILE variable exported by the union/tg5040 toolchains
# 2) standard prefix in the PATH
# 3) search in /opt (usual location of buildroot toolchains)
CROSS_PREFIX="${CROSS_COMPILE:-aarch64-linux-gnu-}"
if ! command -v "${CROSS_PREFIX}gcc" >/dev/null 2>&1; then
    FOUND="$(find /opt /usr/local -name 'aarch64-*-gcc' -type f 2>/dev/null | head -1 || true)"
    if [ -n "$FOUND" ]; then
        CROSS_PREFIX="${FOUND%gcc}"
        export PATH="$(dirname "$FOUND"):$PATH"
    else
        echo "ERROR: no aarch64 gcc found. Run this script inside the tg5040 toolchain (see build/Dockerfile)."
        exit 1
    fi
fi

CC="${CROSS_PREFIX}gcc"
CXX="${CROSS_PREFIX}g++"

echo ">> Toolchain: $CC"
"$CC" --version | head -1

echo ">> Cloning gw-libretro..."
git clone --depth 1 "$REPO_URL" "$WORK_DIR/gw-libretro"

echo ">> Compiling (platform=unix, aarch64, Cortex-A53)..."
# NB: do not overwrite CFLAGS — the Makefile defines essential -D flags
# (gwlua_malloc/free, etc.) and already compiles with -O3 -fPIC.
make -C "$WORK_DIR/gw-libretro" -j"$(nproc)" \
    platform=unix \
    CC="$CC" CXX="$CXX"

echo ">> Checking the architecture..."
file "$WORK_DIR/gw-libretro/gw_libretro.so" | grep -q "aarch64" \
    || { echo "ERROR: the .so is not aarch64!"; exit 1; }

echo ">> glibc versions required by the .so:"
"${CROSS_PREFIX}objdump" -T "$WORK_DIR/gw-libretro/gw_libretro.so" 2>/dev/null \
    | grep -o 'GLIBC_[0-9.]*' | sort -Vu | tail -3 || true

echo ">> Stripping and copying to $DEST"
"${CROSS_PREFIX}strip" "$WORK_DIR/gw-libretro/gw_libretro.so" || true
cp "$WORK_DIR/gw-libretro/gw_libretro.so" "$DEST"

rm -rf "$WORK_DIR"
echo ">> Done: $DEST"