#!/usr/bin/env bash
# Compile gw_libretro.so via Docker, without installing anything on the host.
# Usage: ./build/docker-build.sh  (from the project root)
set -euo pipefail
cd "$(dirname "$0")/.."
docker build -t gw-pak-builder -f build/Dockerfile .
docker run --rm -v "$PWD":/project gw-pak-builder
echo ">> Core available: Emus/tg5040/GW.pak/gw_libretro.so"
