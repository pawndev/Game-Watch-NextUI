#!/usr/bin/env bash
# Package the pak into a NextUI .pakz archive.
#
# A .pakz is simply a zip that holds the SD-card tree (Emus/ and Roms/) to be
# extracted at the root of the device. The archive is written to dist/, which is
# gitignored.
#
# Usage:
#   ./build/package.sh
#
# Requires the core to be built first (Emus/tg5040/GW.pak/gw_libretro.so).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# --- Read metadata from pak.json (jq, with a python3 fallback) --------------
read_json() { # $1 = key
    if command -v jq >/dev/null 2>&1; then
        jq -r ".$1" pak.json
    else
        python3 -c "import json,sys; print(json.load(open('pak.json'))['$1'])"
    fi
}

NAME="$(read_json name)"

DIST_DIR="$PROJECT_ROOT/dist"
ARCHIVE="$DIST_DIR/${NAME}.pakz"

# --- Sanity checks ----------------------------------------------------------
[ -d Emus ] || { echo "ERROR: Emus/ folder not found."; exit 1; }
[ -d Roms ] || { echo "ERROR: Roms/ folder not found."; exit 1; }
if ! ls Emus/*/*.pak/*_libretro.so >/dev/null 2>&1; then
    echo "WARNING: no *_libretro.so core found under Emus/. Build it first (mise run build-core)."
fi

# Preserve the executable bit on launch scripts inside the archive.
find Emus -name 'launch.sh' -exec chmod +x {} +

# --- Build the archive ------------------------------------------------------
mkdir -p "$DIST_DIR"
rm -f "$ARCHIVE" "$ARCHIVE.sha256"

echo ">> Packaging $NAME ..."
zip -r -X "$ARCHIVE" Emus Roms -x '*.DS_Store' -x '__MACOSX/*'

# --- Checksum ---------------------------------------------------------------
if command -v sha256sum >/dev/null 2>&1; then
    (cd "$DIST_DIR" && sha256sum "$(basename "$ARCHIVE")" > "$(basename "$ARCHIVE").sha256")
elif command -v shasum >/dev/null 2>&1; then
    (cd "$DIST_DIR" && shasum -a 256 "$(basename "$ARCHIVE")" > "$(basename "$ARCHIVE").sha256")
fi

echo ">> Done:"
echo "   $ARCHIVE"
[ -f "$ARCHIVE.sha256" ] && echo "   $ARCHIVE.sha256"